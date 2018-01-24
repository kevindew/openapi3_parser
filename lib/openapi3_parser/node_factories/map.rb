# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/error"
require "openapi3_parser/node_factory/map"
require "openapi3_parser/nodes/map"
require "openapi3_parser/validation/error"
require "openapi3_parser/validation/error_collection"

module Openapi3Parser
  module NodeFactories
    class Map
      include NodeFactory::Map

      def initialize(
        context,
        key_input_type: String,
        value_input_type: nil,
        value_factory: nil,
        validate: nil
      )
        @given_key_input_type = key_input_type
        @given_value_input_type = value_input_type
        @given_value_factory = value_factory
        @given_validate = validate
        super(context)
      end

      private

      attr_reader :given_key_input_type, :given_value_input_type,
                  :given_value_factory, :given_validate

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = if value_factory?
                        next_context = Context.next_field(context, key)
                        initialize_value_factory(next_context)
                      else
                        value
                      end
        end
      end

      def validate_type
        error = super
        return error if error
        return unless given_key_input_type
        invalid_keys = context.input.keys.reject do |key|
          key.is_a?(given_key_input_type)
        end
        error = "Expected keys to be of type #{given_key_input_type}"
        return error if invalid_keys.any?
      end

      def validate(input, context)
        given_validate&.call(input, context)
      end

      def validate_input
        errors = validate_value_input_type(processed_input, context)
        Validation::ErrorCollection.combine(super, errors)
      end

      def build_node(input)
        check_value_input_type(input)
        super(input)
      end

      def build_map(data, context)
        Nodes::Map.new(data, context)
      end

      def value_factory?
        !given_value_factory.nil?
      end

      def initialize_value_factory(context)
        factory = given_value_factory
        return factory.new(context) if factory.is_a?(Class)
        factory.call(context)
      end

      def validate_value_input_type(input, context)
        input.each_with_object([]) do |(key, value), memo|
          error = error_for_value_input_type(value)
          next unless error
          memo << Validation::Error.new(
            error, Context.next_field(context, key), self.class
          )
        end
      end

      def check_value_input_type(input)
        input.each do |key, value|
          error = error_for_value_input_type(value)
          next unless error
          next_context = Context.next_field(context, key)
          raise Openapi3Parser::Error::InvalidType,
                "Invalid type for #{next_context.location_summary}. "\
                "#{error}"
        end
      end

      def error_for_value_input_type(value)
        type = given_value_input_type
        return unless type
        "Expected #{type}" unless value.is_a?(type)
      end
    end
  end
end
