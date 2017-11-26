# frozen_string_literal: true

require "openapi3_parser/node_factory"
require "openapi3_parser/validation/error"

module Openapi3Parser
  module NodeFactory
    module Object
      class Validator
        def self.missing_required_fields(input, factory)
          configs = factory.field_configs
          configs.each_with_object([]) do |(name, field_config), memo|
            memo << name if field_config.required?(factory) && input[name].nil?
          end
        end

        def self.unexpected_fields(input, factory)
          unexpected_keys = input.keys - factory.field_configs.keys
          if factory.allowed_extensions?
            unexpected_keys.reject { |k| k =~ NodeFactory::EXTENSION_REGEX }
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
