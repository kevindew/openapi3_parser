# frozen_string_literal: true

require "openapi3_parser/error"

module Openapi3Parser
  module Fields
    class Map
      private_class_method :new

      def initialize(input, context, value_type, key_format)
        @input = input
        @context = context
        @value_type = value_type
        @key_format = key_format
      end

      def self.call(
        input,
        context,
        value_type: Hash,
        key_format: nil,
        &block
      )
        new(input, context, value_type, key_format).call(&block)
      end

      def self.reference_input(
        input,
        context,
        value_type: Hash,
        key_format: nil,
        &block
      )
        call(
          input, context, value_type: value_type, key_format: key_format
        ) do |field_input, field_context|
          field_context.possible_reference(field_input, &block)
        end
      end

      def call(&block)
        validate_keys
        validate_values

        input.each_with_object({}) do |(key, value), memo|
          memo[key] = if block
                        yield(value, context.next_namespace(key), key)
                      else
                        value
                      end
        end
      end

      private

      attr_reader :input, :context, :value_type, :key_format

      def validate_keys
        return unless key_format
        invalid_keys = input.keys.reject { |key| key =~ key_format }
        return if invalid_keys.empty?

        raise Openapi3Parser::Error, "Invalid field names for "\
          "#{context.stringify_namespace}: #{invalid_keys.join(', ')}"
      end

      def validate_values
        return unless value_type
        invalid = input.reject do |key, value|
          if value_type.is_a?(Proc)
            value.call(value, key)
          else
            value.is_a?(value_type)
          end
        end
        return if invalid.empty?

        raise Openapi3Parser::Error, "Unexpected type for "\
          "#{context.stringify_namespace}: #{invalid.keys.join(', ')}"
      end
    end
  end
end
