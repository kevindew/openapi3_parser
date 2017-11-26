# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # rubocop:disable ClassLength
    class Schema
      include Node::Object

      def title
        node_data["title"]
      end

      def multiple_of
        node_data["multipleOf"]
      end

      def maximum
        node_data["maximum"]
      end

      def exclusive_maximum?
        node_data["exclusiveMaximum"]
      end

      def minimum
        node_data["minimum"]
      end

      def exclusive_minimum?
        node_data["exclusiveMinimum"]
      end

      def max_length
        node_data["maxLength"]
      end

      def min_length
        node_data["minLength"]
      end

      def pattern
        node_data["pattern"]
      end

      def max_items
        node_data["maxItems"]
      end

      def min_items
        node_data["minItems"]
      end

      def unique_items?
        node_data["uniqueItems"]
      end

      def max_properties
        node_data["maxProperties"]
      end

      def min_properties
        node_data["minProperties"]
      end

      def required
        node_data["required"]
      end

      def enum
        node_data["enum"]
      end

      def type
        node_data["type"]
      end

      def all_of
        node_data["allOf"]
      end

      def one_of
        node_data["oneOf"]
      end

      def any_of
        node_data["anyOf"]
      end

      def not
        node_data["not"]
      end

      def items
        node_data["items"]
      end

      def properties
        node_data["properties"]
      end

      def additional_properties?
        node_data["additionalProperties"] != false
      end

      def additional_properties_schema
        properties = node_data["additionalProperties"]
        return if [true, false].include?(properties)
        properties
      end

      def description
        node_data["description"]
      end

      def format
        node_data["format"]
      end

      def default
        node_data["default"]
      end

      def nullable?
        node_data["nullable"]
      end

      def disciminator
        node_data["discriminator"]
      end

      def read_only?
        node_data["readOnly"]
      end

      def write_only?
        node_data["writeOnly"]
      end

      def xml
        node_data["xml"]
      end

      def external_docs
        node_data["externalDocs"]
      end

      def example
        node_data["example"]
      end

      def deprecated?
        node_data["deprecated"]
      end
    end
    # rubocop:enable ClassLength
  end
end
