# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/error"
require "openapi3_parser/node_factory"
require "openapi3_parser/node/array"
require "openapi3_parser/validation/error"
require "openapi3_parser/validation/error_collection"

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

      def validate(input, _context)
        given_validate&.call(input, self)
      end

      def validate_input
        value_errors = processed_input.flat_map do |value|
          value.respond_to?(:errors) ? value.errors.to_a : []
        end
        errors = value_errors + validate_value_input_type(processed_input,
                                                          context)
        Validation::ErrorCollection.combine(super, errors)
      end

      def build_node(input)
        check_value_input_type(input)
        data = input.map do |value|
          value.respond_to?(:node) ? value.node : value
        end
        build_array(data, context)
      end

      def build_array(data, context)
        Node::Array.new(data, context)
      end

      def build_resolved_input
        processed_input.map do |value|
          value.respond_to?(:resolved_input) ? value.resolved_input : value
        end
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
            error, Context.next_field(context, i), self.class
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
