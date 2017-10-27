require "openapi_parser/error"

module OpenapiParser
  module Fields
    class Map
      private_class_method :new

      def initialize(input, context, require_objects, key_format)
        @input = input
        @context = context
        @require_objects = require_objects
        @key_format = key_format
      end

      def self.call(
        input,
        context,
        require_objects: true,
        key_format: nil,
        &block
      )
        new(input, context, require_objects, key_format).call(&block)
      end

      def call(&block)
        validate_keys if key_format
        validate_objects if require_objects

        input.each_with_object({}) do |(key, value), memo|
          memo[key] = if block
                        block.call(value, context.next_namespace(key), key)
                      else
                        value
                      end
        end
      end

      private

      attr_reader :input, :context, :require_objects, :key_format

      def validate_keys
        invalid_keys = input.keys.reject { |key| key =~ key_format }
        unless invalid_keys.empty?
          raise OpenapiParser::Error, "Invalid field names for "\
            "#{context.stringify_namespace}: #{invalid_keys.join(', ')}"
        end
      end

      def validate_objects
        non_objects = input.reject { |_, value| value.respond_to?(:keys) }
        unless non_objects.empty?
          raise OpenapiParser::Error, "Expected objects for "\
            "#{context.stringify_namespace}: #{non_objects.keys.join(', ')}"
        end
      end
    end
  end
end
