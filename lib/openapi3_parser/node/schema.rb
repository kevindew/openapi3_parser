# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject
    # rubocop:disable ClassLength
    class Schema < Node::Object
      # @return [String, nil]
      def title
        node_data["title"]
      end

      # @return [Numeric, nil]
      def multiple_of
        node_data["multipleOf"]
      end

      # @return [Integer, nil]
      def maximum
        node_data["maximum"]
      end

      # @return [Boolean]
      def exclusive_maximum?
        node_data["exclusiveMaximum"]
      end

      # @return [Integer, nil]
      def minimum
        node_data["minimum"]
      end

      # @return [Boolean]
      def exclusive_minimum?
        node_data["exclusiveMinimum"]
      end

      # @return [Integer, nil]
      def max_length
        node_data["maxLength"]
      end

      # @return [Integer]
      def min_length
        node_data["minLength"]
      end

      # @return [String, nil]
      def pattern
        node_data["pattern"]
      end

      # @return [Integer, nil]
      def max_items
        node_data["maxItems"]
      end

      # @return [Integer]
      def min_items
        node_data["minItems"]
      end

      # @return [Boolean]
      def unique_items?
        node_data["uniqueItems"]
      end

      # @return [Integer, nil]
      def max_properties
        node_data["maxProperties"]
      end

      # @return [Integer]
      def min_properties
        node_data["minProperties"]
      end

      # @return [Node::Array<String>, nil]
      def required
        node_data["required"]
      end

      # @return [Node::Array<Object>, nil]
      def enum
        node_data["enum"]
      end

      # @return [String, nil]
      def type
        node_data["type"]
      end

      # @return [Node::Array<Schema>, nil]
      def all_of
        node_data["allOf"]
      end

      # @return [Node::Array<Schema>, nil]
      def one_of
        node_data["oneOf"]
      end

      # @return [Node::Array<Schema>, nil]
      def any_of
        node_data["anyOf"]
      end

      # @return [Schema, nil]
      def not
        node_data["not"]
      end

      # @return [Schema, nil]
      def items
        node_data["items"]
      end

      # @return [Map<String, Schema>]
      def properties
        node_data["properties"]
      end

      # @return [Boolean]
      def additional_properties?
        node_data["additionalProperties"] != false
      end

      # @return [Schema, nil]
      def additional_properties_schema
        properties = node_data["additionalProperties"]
        return if [true, false].include?(properties)
        properties
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [String, nil]
      def format
        node_data["format"]
      end

      # @return [Any]
      def default
        node_data["default"]
      end

      # @return [Boolean]
      def nullable?
        node_data["nullable"]
      end

      # @return [Discriminator, nil]
      def disciminator
        node_data["discriminator"]
      end

      # @return [Boolean]
      def read_only?
        node_data["readOnly"]
      end

      # @return [Boolean]
      def write_only?
        node_data["writeOnly"]
      end

      # @return [Xml, nil]
      def xml
        node_data["xml"]
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        node_data["externalDocs"]
      end

      # @return [Any]
      def example
        node_data["example"]
      end

      # @return [Boolean]
      def deprecated?
        node_data["deprecated"]
      end
    end
    # rubocop:enable ClassLength
  end
end
