# frozen_string_literal: true

require "openapi3_parser/node_factory/object/validator"
require "openapi3_parser/error"

module Openapi3Parser
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
          input.each_with_object({}) do |(key, value), memo|
            memo[key] = resolve_value(key, value)
          end
        end

        private

        attr_reader :input, :factory

        def context
          factory.context
        end

        def check_required_fields
          fields = Validator.missing_required_fields(input, factory)
          return if fields.empty?
          raise Openapi3Parser::Error,
                "Missing required fields for "\
                  "#{context.stringify_namespace}: #{fields.join(', ')}"
        end

        def check_unexpected_fields
          fields = Validator.unexpected_fields(input, factory)
          return if fields.empty?
          raise Openapi3Parser::Error,
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
          input = context.input.nil? ? nil : context.input[name]
          error = field_config.input_type_error(input, factory)

          return unless error
          raise Openapi3Parser::Error,
                "Invalid type for "\
                  "#{field_context.stringify_namespace}: #{error}"
        end

        def check_validation_errors(name, field_config)
          field_context = context.next_namespace(name)
          errors = field_config.validation_errors(input[name], factory)

          return unless errors.any?
          raise Openapi3Parser::Error,
                "Invalid field for #{field_context.stringify_namespace}: "\
                "#{errors.join(', ')}"
        end

        def resolve_value(key, value)
          configs = factory.field_configs
          return configs[key]&.default(factory) if value.nil?
          default_value(configs[key], value)
        end

        def default_value(config, value)
          resolved_value = value.respond_to?(:node) ? value.node : value

          # let a field config default take precedence if value is a nil_input?
          if value.respond_to?(:nil_input?) && value.nil_input?
            default = config&.default(factory)
            default.nil? ? resolved_value : default
          else
            resolved_value
          end
        end
      end
    end
  end
end
