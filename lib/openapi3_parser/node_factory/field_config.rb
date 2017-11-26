# frozen_string_literal: true

require "openapi3_parser/error"

module Openapi3Parser
  module NodeFactory
    class FieldConfig
      attr_reader :given_input_type, :given_factory, :given_required,
                  :given_default, :given_validate

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

      def initialize_factory(context, factory)
        if given_factory.is_a?(Class)
          given_factory.new(context)
        elsif given_factory.is_a?(Symbol)
          factory.send(given_factory, context)
        else
          given_factory.call(context)
        end
      end

      def required?(_factory)
        given_required
      end

      def input_type_error(input, factory)
        return if !given_input_type || input.nil?
        return boolean_error(input) if given_input_type == :boolean
        resolve_type_error(input, factory)
      end

      def validation_errors(input, factory)
        return [] if !given_validate || input.nil?
        errors = resolve_validation_errors(input, factory)
        Array(errors)
      end

      def default(factory)
        return given_default.call if given_default.is_a?(Proc)
        return factory.send(given_default) if given_default.is_a?(Symbol)
        given_default
      end

      private

      def boolean_error(input)
        "Expected a boolean" unless [true, false].include?(input)
      end

      def resolve_type_error(input, factory)
        if given_input_type.is_a?(Proc)
          given_input_type.call(input)
        elsif given_input_type.is_a?(Symbol)
          factory.send(given_input_type, input)
        elsif !input.is_a?(given_input_type)
          "Expected a #{given_input_type}"
        end
      end

      def resolve_validation_errors(input, factory)
        if given_validate.is_a?(Proc)
          given_validate.call(input)
        elsif given_validate.is_a?(Symbol)
          factory.send(given_validate, input)
        else
          raise Error, "Expected a Proc or Symbol for validate"
        end
      end
    end
  end
end
