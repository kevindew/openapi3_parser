# frozen_string_literal: true

require "openapi_parser/node_factory/object/validator"
require "openapi_parser/error"

module OpenapiParser
  module NodeFactory
    module Object
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
    end
  end
end
