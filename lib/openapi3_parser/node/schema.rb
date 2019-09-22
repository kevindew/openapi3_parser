# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject
    # rubocop:disable ClassLength
    class Schema < Node::Object
      # @return [String, nil]
      def title
        self["title"]
      end

      # @return [Numeric, nil]
      def multiple_of
        self["multipleOf"]
      end

      # @return [Integer, nil]
      def maximum
        self["maximum"]
      end

      # @return [Boolean]
      def exclusive_maximum?
        self["exclusiveMaximum"]
      end

      # @return [Integer, nil]
      def minimum
        self["minimum"]
      end

      # @return [Boolean]
      def exclusive_minimum?
        self["exclusiveMinimum"]
      end

      # @return [Integer, nil]
      def max_length
        self["maxLength"]
      end

      # @return [Integer]
      def min_length
        self["minLength"]
      end

      # @return [String, nil]
      def pattern
        self["pattern"]
      end

      # @return [Integer, nil]
      def max_items
        self["maxItems"]
      end

      # @return [Integer]
      def min_items
        self["minItems"]
      end

      # @return [Boolean]
      def unique_items?
        self["uniqueItems"]
      end

      # @return [Integer, nil]
      def max_properties
        self["maxProperties"]
      end

      # @return [Integer]
      def min_properties
        self["minProperties"]
      end

      # @return [Node::Array<String>, nil]
      def required
        self["required"]
      end

      # @return [Node::Array<Object>, nil]
      def enum
        self["enum"]
      end

      # @return [String, nil]
      def type
        self["type"]
      end

      # @return [Node::Array<Schema>, nil]
      def all_of
        self["allOf"]
      end

      # @return [Node::Array<Schema>, nil]
      def one_of
        self["oneOf"]
      end

      # @return [Node::Array<Schema>, nil]
      def any_of
        self["anyOf"]
      end

      # @return [Schema, nil]
      def not
        self["not"]
      end

      # @return [Schema, nil]
      def items
        self["items"]
      end

      # @return [Map<String, Schema>]
      def properties
        self["properties"]
      end

      # @return [Boolean]
      def additional_properties?
        self["additionalProperties"] != false
      end

      # @return [Schema, nil]
      def additional_properties_schema
        properties = self["additionalProperties"]
        return if [true, false].include?(properties)
        properties
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [String, nil]
      def format
        self["format"]
      end

      # @return [Any]
      def default
        self["default"]
      end

      # @return [Boolean]
      def nullable?
        self["nullable"]
      end

      # @return [Discriminator, nil]
      def disciminator
        self["discriminator"]
      end

      # @return [Boolean]
      def read_only?
        self["readOnly"]
      end

      # @return [Boolean]
      def write_only?
        self["writeOnly"]
      end

      # @return [Xml, nil]
      def xml
        self["xml"]
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        self["externalDocs"]
      end

      # @return [Any]
      def example
        self["example"]
      end

      # @return [Boolean]
      def deprecated?
        self["deprecated"]
      end
    end
    # rubocop:enable ClassLength
  end
end
