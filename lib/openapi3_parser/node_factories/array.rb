# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/error"
require "openapi3_parser/node_factory"
require "openapi3_parser/nodes/array"
require "openapi3_parser/validation/error"

module Openapi3Parser
  module NodeFactories
    class Array
      include NodeFactory
      input_type ::Array

      def initialize(
        context,
        default: [],
        value_input_type: nil,
        value_factory: nil,
        validate: nil
      )
        @default = default
        @given_value_input_type = value_input_type
        @given_value_factory = value_factory
        @given_validate = validate
        super(context)
      end

      private

      attr_reader :default, :given_value_input_type,
                  :given_value_factory, :given_validate

      def process_input(input)
        input.each_with_index.map do |value, i|
          if value_factory?
            initialize_value_factory(Context.next_field(context, i))
          else
            value
          end
        end
      end

      def validate(input, context)
        given_validate&.call(input, context)
      end

      def validate_input(error_collection)
        super(error_collection)
        processed_input.each do |value|
          next unless value.respond_to?(:errors)
          error_collection.merge(value.errors)
        end
        error_collection.merge(
          validate_value_input_type(processed_input, context)
        )
      end

      def build_node(input)
        check_value_input_type(input)
        data = input.map do |value|
          value.respond_to?(:node) ? value.node : value
        end
        build_array(data, context)
      end

      def build_array(data, context)
        Nodes::Array.new(data, context)
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
        input.each_with_index.each_with_object([]) do |(value, i), memo|
          error = error_for_value_input_type(value)
          next unless error
          memo << Validation::Error.new(
            Context.next_field(context, i), error
          )
        end
      end

      def check_value_input_type(input)
        input.each_with_index do |value, i|
          error = error_for_value_input_type(value)
          next unless error
          next_context = Context.next_field(context, i)
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
