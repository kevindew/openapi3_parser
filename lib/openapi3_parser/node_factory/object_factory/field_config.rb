# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ObjectFactory
      class FieldConfig
        def initialize(
          input_type: nil,
          factory: nil,
          required: false,
          default: nil,
          validate: nil
        )
          @given_input_type = input_type
          @given_factory = factory
          @given_required = required
          @given_default = default
          @given_validate = validate
        end

        def factory?
          !given_factory.nil?
        end

        def initialize_factory(context, parent_factory = nil)
          case given_factory
          when Class
            given_factory.new(context)
          when Symbol
            parent_factory.send(given_factory, context)
          else
            given_factory.call(context)
          end
        end

        def required?
          given_required
        end

        def check_input_type(validatable, building_node: false)
          return true if !given_input_type || validatable.input.nil?

          if building_node
            TypeChecker.raise_on_invalid_type(validatable.context,
                                              type: given_input_type)
          else
            TypeChecker.validate_type(validatable, type: given_input_type)
          end
        end

        def validate_field(validatable, building_node: false)
          return true if !given_validate || validatable.input.nil?

          run_validation(validatable)

          return validatable.errors.empty? unless building_node
          return true if validatable.errors.empty?

          error = validatable.errors.first
          location_summary = error.context.location_summary
          raise Error::InvalidData,
                "Invalid data for #{location_summary}: #{error.message}"
        end

        def default(factory = nil)
          return given_default.call if given_default.is_a?(Proc)
          return factory&.send(given_default) if given_default.is_a?(Symbol)

          given_default
        end

        private

        attr_reader :given_input_type, :given_factory, :given_required,
                    :given_default, :given_validate

        def run_validation(validatable)
          if given_validate.is_a?(Symbol)
            validatable.factory.send(given_validate, validatable)
          else
            given_validate.call(validatable)
          end
        end
      end
    end
  end
end
