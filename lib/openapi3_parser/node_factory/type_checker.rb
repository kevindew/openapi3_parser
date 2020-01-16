# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class TypeChecker
      def self.validate_type(validatable, type:, context: nil)
        new(type).validate_type(validatable, context)
      end

      def self.raise_on_invalid_type(context, type:)
        new(type).raise_on_invalid_type(context)
      end

      def self.validate_keys(validatable, type:, context: nil)
        new(type).validate_keys(validatable, context)
      end

      def self.raise_on_invalid_keys(context, type:)
        new(type).raise_on_invalid_keys(context)
      end

      private_class_method :new

      def initialize(type)
        @type = type
      end

      def validate_type(validatable, context)
        return true unless type

        context ||= validatable.context
        valid_type?(context.input).tap do |valid|
          next if valid

          validatable.add_error("Invalid type. #{field_error_message}",
                                context)
        end
      end

      def validate_keys(validatable, context)
        return true unless type

        context ||= validatable.context
        valid_keys?(context.input).tap do |valid|
          next if valid

          validatable.add_error("Invalid keys. #{keys_error_message}",
                                context)
        end
      end

      def raise_on_invalid_type(context)
        return true if !type || valid_type?(context.input)

        raise Error::InvalidType,
              "Invalid type for #{context.location_summary}: "\
              "#{field_error_message}"
      end

      def raise_on_invalid_keys(context)
        return true if !type || valid_keys?(context.input)

        raise Error::InvalidType,
              "Invalid keys for #{context.location_summary}: "\
              "#{keys_error_message}"
      end

      private

      attr_reader :type

      def valid_type?(input)
        return [true, false].include?(input) if type == :boolean

        unless type.is_a?(Class)
          raise Error::UnvalidatableType,
                "Expected #{type} to be a Class not a #{type.class}"
        end

        input.is_a?(type)
      end

      def field_error_message
        "Expected #{type_name_for_error}"
      end

      def keys_error_message
        "Expected keys to be of type #{type_name_for_error}"
      end

      def type_name_for_error
        if type == Hash
          "Object"
        elsif type == :boolean
          "Boolean"
        else
          type.to_s
        end
      end

      def valid_keys?(input)
        input.keys.all? { |key| valid_type?(key) }
      end
    end
  end
end
