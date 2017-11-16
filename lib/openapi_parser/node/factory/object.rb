# frozen_string_literal: true

require "openapi_parser/node/factory"
require "openapi_parser/node/factory/field_config"
require "openapi_parser/error"
require "openapi_parser/validation/error"

module OpenapiParser
  module Node
    module Factory
      module Object
        include Factory

        module ClassMethods
          def field(name, **options)
            @field_configs ||= {}
            @field_configs[name] = FieldConfig.new(options)
          end

          def field_configs
            @field_configs || {}
          end

          def allow_extensions
            @allow_extensions = true
          end

          def disallow_extensions
            @allow_extensions = false
          end

          def allowed_extensions?
            @allow_extensions == true
          end
        end

        def self.included(base)
          base.extend(Factory::ClassMethods)
          base.extend(ClassMethods)
          base.class_eval do
            input_type Hash
          end
        end

        def allowed_extensions?
          self.class.allowed_extensions?
        end

        def field_configs
          self.class.field_configs || {}
        end

        private

        def process_input(input)
          field_configs.each_with_object(input.dup) do |(field, config), memo|
            next if !config.factory? || !memo[field]
            next_context = context.next_namespace(field)
            memo[field] = config.initialize_factory(
              next_context, self
            )
          end
        end

        def validate_input(error_collection)
          super(error_collection)
          validator = Validator.new(processed_input, self)
          error_collection.tap { |ec| ec.append(*validator.errors) }
        end

        def build_node(input)
          data = NodeBuilder.new(input, self).data
          build_object(data, context)
        end

        def build_object(data, _context)
          data
        end

        class NodeBuilder
          def initialize(input, factory)
            @input = input
            @factory = factory
          end

          def data
            check_required_fields
            check_unexpected_fields
            check_fields_valid
            data = input.each_with_object({}) do |(key, value), memo|
              memo[key] = value.respond_to?(:node) ? value.node : value
            end
            apply_defaults(data)
          end

          private

          attr_reader :input, :factory

          def context
            factory.context
          end

          def check_required_fields
            fields = Validator.missing_required_fields(input, factory)
            return if fields.empty?
            raise OpenapiParser::Error,
                  "Missing required fields for "\
                    "#{context.stringify_namespace}: #{fields.join(', ')}"
          end

          def check_unexpected_fields
            fields = Validator.unexpected_fields(input, factory)
            return if fields.empty?
            raise OpenapiParser::Error,
                  "Unexpected fields for #{context.stringify_namespace}: "\
                    "#{fields.join(', ')}"
          end

          def check_fields_valid
            factory.field_configs.each do |name, field_config|
              check_type_error(name, field_config)
              check_validation_errors(name, field_config)
            end
          end

          def check_type_error(name, field_config)
            field_context = context.next_namespace(name)
            error = field_config.input_type_error(input[name], factory)

            return unless error
            raise OpenapiParser::Error,
                  "Invalid type for "\
                    "#{field_context.stringify_namespace}: #{error}"
          end

          def check_validation_errors(name, field_config)
            field_context = context.next_namespace(name)
            errors = field_config.validation_errors(input[name], factory)

            return unless errors.any?
            raise OpenapiParser::Error,
                  "Invalid field for #{field_context.stringify_namespace}: "\
                  "#{errors.join(', ')}"
          end

          def apply_defaults(data)
            configs = factory.field_configs
            configs.each_with_object(data) do |(name, field_config), _memo|
              data[name] = field_config.default(factory) if data[name].nil?
            end
          end
        end

        class Validator
          def self.missing_required_fields(input, factory)
            configs = factory.field_configs
            configs.each_with_object([]) do |(name, field_config), memo|
              if field_config.required?(factory) && input[name].nil?
                memo << name
              end
            end
          end

          def self.unexpected_fields(input, factory)
            unexpected_keys = input.keys - factory.field_configs.keys
            if factory.allowed_extensions?
              unexpected_keys.reject { |k| k =~ Node::EXTENSION_REGEX }
            else
              unexpected_keys
            end
          end

          def initialize(input, factory)
            @input = input
            @factory = factory
          end

          def errors
            [
              missing_required_fields_error,
              unexpected_fields_error,
              invalid_field_errors
            ].flatten.compact
          end

          private

          attr_reader :input, :factory

          def context
            factory.context
          end

          def missing_required_fields_error
            fields = self.class.missing_required_fields(input, factory)
            return unless fields.any?
            Validation::Error.new(
              context.namespace,
              "Missing required fields: #{fields.join(', ')}"
            )
          end

          def unexpected_fields_error
            fields = self.class.unexpected_fields(input, factory)
            return unless fields.any?
            Validation::Error.new(
              context.namespace,
              "Unexpected fields: #{fields.join(', ')}"
            )
          end

          def invalid_field_errors
            factory.field_configs.inject([]) do |memo, (name, field_config)|
              memo + field_errors(name, field_config)
            end
          end

          def field_errors(name, field_config)
            field = input[name]
            return [] if field.nil?
            return field.errors.to_a if field.respond_to?(:errors)
            type_error = build_type_error(name, field_config)
            return [type_error] if type_error
            build_validation_errors(name, field_config)
          end

          def build_type_error(name, field_config)
            type_error = field_config.input_type_error(input[name], factory)
            return unless type_error
            Validation::Error.new(
              context.next_namespace(name),
              "Invalid type: #{type_error}"
            )
          end

          def build_validation_errors(name, field_config)
            field_config.validation_errors(
              input[name], factory
            ).map do |error|
              Validation::Error.new(
                context.next_namespace(name),
                "Invalid field: #{error}"
              )
            end
          end
        end
      end
    end
  end
end
