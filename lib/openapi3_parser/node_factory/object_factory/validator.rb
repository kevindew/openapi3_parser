# frozen_string_literal: true

require "forwardable"

require "openapi3_parser/array_sentence"
require "openapi3_parser/error"
require "openapi3_parser/validation/validatable"

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class Validator
        private_class_method :new
        attr_reader :factory, :validatable, :building_node

        def self.call(*args)
          new(*args).call
        end

        def initialize(factory, validatable, building_node)
          @factory = factory
          @validatable = validatable
          @building_node = building_node
        end

        def call
          CheckRequiredFields.call(self)
          CheckUnexpectedFields.call(self)
          CheckMututallyExclusiveFields.call(self)
          CheckInvalidFields.call(self)
          CheckFactoryValidations.call(self)
        end

        def location_summary
          factory.context.location_summary
        end

        class CheckRequiredFields
          using ArraySentence
          private_class_method :new

          def self.call(validator)
            new.call(validator)
          end

          def call(validator)
            fields = missing_required_fields(validator)
            return if fields.empty?

            if validator.building_node
              raise Openapi3Parser::Error::MissingFields,
                    "Missing required fields for "\
                    "#{validator.location_summary}: #{fields.sentence_join}"
            else
              validator.validatable.add_error(
                "Missing required fields: #{fields.sentence_join}"
              )
            end
          end

          private

          def missing_required_fields(validator)
            configs = validator.factory.field_configs
            configs.each_with_object([]) do |(name, field_config), memo|
              field = validator.factory.raw_input[name]
              memo << name if field_config.required? && field.nil?
            end
          end
        end

        class CheckUnexpectedFields
          using ArraySentence
          private_class_method :new

          def self.call(validator)
            new.call(validator)
          end

          def call(validator)
            fields = unexpected_fields(validator)
            return if fields.empty?

            if validator.building_node
              raise Openapi3Parser::Error::UnexpectedFields,
                    "Unexpected fields for #{validator.location_summary}: "\
                    "#{fields.sentence_join}"
            else
              validator.validatable.add_error(
                "Unexpected fields: #{fields.sentence_join}"
              )
            end
          end

          private

          def unexpected_fields(validator)
            factory = validator.factory
            extra_keys = factory.raw_input.keys - factory.field_configs.keys
            if factory.allowed_extensions?
              extra_keys.reject do |key|
                key =~ NodeFactory::EXTENSION_REGEX
              end
            else
              extra_keys
            end
          end
        end

        class CheckMututallyExclusiveFields
          private_class_method :new

          def self.call(validator)
            new.call(validator)
          end

          def call(validator)
            mutually_exclusive = MututallyExclusiveFieldErrors.new(
              validator.factory
            )

            handle_required_errors(validator,
                                   mutually_exclusive.required_errors)
            handle_exclusive_errors(validator,
                                    mutually_exclusive.exclusive_errors)
          end

          private

          def handle_required_errors(validator, required_errors)
            return unless required_errors.any?

            if validator.building_node
              raise Error::MissingFields,
                    "Mutually exclusive fields for "\
                    "#{validator.location_summary}: #{required_errors.first}"
            else
              validator.validatable.add_errors(required_errors)
            end
          end

          def handle_exclusive_errors(validator, exclusive_errors)
            return unless exclusive_errors.any?

            if validator.building_node
              raise Error::UnexpectedFields,
                    "Mutually exclusive fields for "\
                    "#{validator.location_summary}: "\
                    "#{exclusive_errors.first}"
            else
              validator.validatable.add_errors(exclusive_errors)
            end
          end
        end

        class MututallyExclusiveFieldErrors
          using ArraySentence

          def initialize(factory)
            @factory = factory
          end

          def required_errors
            errors[:required]
          end

          def exclusive_errors
            errors[:exclusive]
          end

          def errors
            @errors ||= begin
                          default = { required: [], exclusive: [] }
                          factory
                            .mutually_exclusive_fields
                            .each_with_object(default) do |exclusive, errors|
                              add_error(errors, exclusive)
                            end
                        end
          end

          private

          attr_reader :factory

          def add_error(errors, mutually_exclusive)
            fields = mutually_exclusive.fields
            number_non_nil = count_non_nil_fields(fields, factory.raw_input)
            if number_non_nil.zero? && mutually_exclusive.required
              errors[:required] << required_error(fields)
            elsif number_non_nil > 1
              errors[:exclusive] << exclusive_error(fields)
            end
          end

          def count_non_nil_fields(fields, input)
            fields.count do |field|
              data = input[field]
              data.respond_to?(:nil_input?) ? !data.nil_input? : !data.nil?
            end
          end

          def required_error(fields)
            "One of #{fields.sentence_join} is required"
          end

          def exclusive_error(fields)
            "#{fields.sentence_join} are mutually exclusive fields"
          end
        end

        class CheckInvalidFields
          extend Forwardable
          attr_reader :validator
          def_delegators :validator, :factory, :building_node, :validatable
          private_class_method :new

          def self.call(validator)
            new(validator).call
          end

          def initialize(validator)
            @validator = validator
          end

          def call
            factory.data.each do |name, field|
              if field.respond_to?(:errors)
                # We don't add errors when we're building a node as they will
                # be raised when that child node is built
                validatable.add_errors(field.errors) unless building_node
              end

              if factory.field_configs[name]
                check_field(name, factory.field_configs[name])
              end
            end
          end

          private

          def check_field(name, field_config)
            return if factory.raw_input[name].nil?

            field_validatable = Validation::Validatable.new(
              factory,
              context: Context.next_field(factory.context, name)
            )

            valid_input_type = field_config.check_input_type(field_validatable,
                                                             building_node)

            if valid_input_type
              field_config.validate_field(field_validatable, building_node)
            end

            validatable.add_errors(field_validatable.errors)
          end
        end

        class CheckFactoryValidations
          private_class_method :new

          def self.call(validator)
            new.call(validator)
          end

          def call(validator)
            run_validations(validator)

            errors = validator.validatable.errors

            return if errors.empty? || !validator.building_node

            location_summary = errors.first.context.location_summary
            raise Error::InvalidData,
                  "Invalid data for #{location_summary}: "\
                  "#{errors.first.message}"
          end

          private

          def run_validations(validator)
            validator.factory.validations.each do |validation|
              if validation.respond_to?(:call)
                validation.call(validator.validatable)
              elsif validation.is_a?(Symbol)
                validator.factory.send(validation, validator.validatable)
              else
                raise Error::NotCallable, "expected a symbol or a callable"
              end
            end
          end
        end
      end
    end
  end
end
