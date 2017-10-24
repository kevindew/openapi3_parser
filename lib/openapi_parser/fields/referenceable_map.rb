require "openapi_parser/error"

module OpenapiParser
  module Fields
    class ReferenceableMap
      private_class_method :new

      VALID_FIELD_FORMAT = /^[a-zA-Z0-9\.\-_]+$/

      def initialize(input, document, namespace, require_objects)
        @input = input
        @document = document
        @namespace = namespace
        @require_objects = require_objects
      end

      def self.call(input, document, namespace, require_objects: true, &block)
        new(input, document, namespace, require_objects).call(&block)
      end

      def call(&block)
        validate_keys
        validate_objects if require_objects

        input.each_with_object({}) do |(key, value), memo|
          memo[key] = if block
                        block.call(value, document, namespace + [key])
                      else
                        value
                      end
        end
      end

      private

      attr_reader :input, :document, :namespace, :require_objects

      def validate_keys
        invalid_keys = input.keys.reject { |key| key =~ VALID_FIELD_FORMAT }
        unless invalid_keys.empty?
          raise OpenapiParser::Error, "Invalid field names for "\
            "#{namespace.join('/')}: #{invalid_keys.join(', ')}"
        end
      end

      def validate_objects
        non_objects = input.reject { |_, value| value.respond_to?(:keys) }
        unless non_objects.empty?
          raise OpenapiParser::Error, "Expected objects for "\
            "#{namespace.join('/')}: #{non_objects.keys.join(', ')}"
        end
      end
    end
  end
end
