# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/discriminator"
require "openapi_parser/nodes/xml"
require "openapi_parser/nodes/external_documentation"

module OpenapiParser
  module Nodes
    # rubocop:disable ClassLength
    class Schema
      include Node

      HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT = lambda { |i|
        i.is_a?(Array) && i.map(&:class).uniq == [Hash] && i.count.positive?
      }

      allow_extensions

      field "title", input_type: String
      field "multipleOf", input_type: Numeric
      field "maximum", input_type: Integer
      field "exclusiveMaximum", input_type: :boolean, default: false
      field "minimum", input_type: Integer
      field "exclusiveMinimum", input_type: :boolean, default: false
      field "maxLength", input_type: ->(i) { i.is_a?(Integer) && i.positive? }
      field "minLength",
            input_type: ->(i) { i.is_a?(Integer) && i >= 0 },
            default: 0
      field :pattern, input_type: String
      field "maxItems", input_type: ->(i) { i.is_a?(Integer) && i.positive? }
      field "minItems",
            input_type: ->(i) { i.is_a?(Integer) && i >= 0 },
            default: 0
      field "uniqueItems", input_type: :boolean, default: false
      field "maxProperties",
            input_type: ->(i) { i.is_a?(Integer) && i.positive? }
      field "minProperties",
            input_type: ->(i) { i.is_a?(Integer) && i >= 0 },
            default: 0
      field "required", input_type: :required_input_type
      field "enum",
            input_type: ->(i) { i.is_a?(Array) && i.uniq.count == i.count }

      field "type", input_type: String
      field "allOf",
            input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
            build: :build_schema_array
      field "oneOf",
            input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
            build: :build_schema_array
      field "anyOf",
            input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
            build: :build_schema_array
      field "not",
            input_type: Hash,
            build: :build_referenceable_schema
      field "items",
            input_type: Hash,
            build: :build_referenceable_schema
      field "properties", input_type: Hash, build: :build_properties
      field "additionalProperties",
            build: :build_additional_properties,
            input_type: ->(i) { [true, false].include?(i) || i.is_a?(Hash) }
      field "description", input_type: String
      field "format", input_type: String
      field "default"

      field "nullable", input_type: :boolean, default: false
      field "discriminator",
            input_type: Hash,
            build: ->(input, context) { Discriminator.new(input, context) }
      field "readOnly", input_type: :boolean, default: false
      field "writeOnly", input_type: :boolean, default: false
      field "xml",
            input_type: Hash,
            build: ->(input, context) { Xml.new(input, context) }
      field "externalDocs",
            input_type: Hash,
            build: :build_external_docs
      field "example"
      field "deprecated", input_type: :boolean, default: false

      def title
        fields["title"]
      end

      def multiple_of
        fields["multipleOf"]
      end

      def maximum
        fields["maximum"]
      end

      def exclusive_maximum
        fields["exclusiveMaximum"]
      end

      def minimum
        fields["minimum"]
      end

      def exclusive_minimum
        fields["exclusiveMinimum"]
      end

      def max_length
        fields["maxLength"]
      end

      def min_length
        fields["minLength"]
      end

      def pattern
        fields["pattern"]
      end

      def max_items
        fields["maxItems"]
      end

      def min_items
        fields["minItems"]
      end

      def unique_items
        fields["uniqueItems"]
      end

      def max_properties
        fields["maxProperties"]
      end

      def min_properties
        fields["minProperties"]
      end

      def required
        fields["required"]
      end

      def enum
        fields["enum"]
      end

      def type
        fields["type"]
      end

      def all_of
        fields["allOf"]
      end

      def one_of
        fields["oneOf"]
      end

      def any_of
        fields["anyOf"]
      end

      def not
        fields["not"]
      end

      def items
        fields["items"]
      end

      def properties
        fields["properties"]
      end

      def additional_properties
        fields["additionalProperties"]
      end

      def description
        fields["description"]
      end

      def format
        fields["format"]
      end

      def default
        fields["default"]
      end

      def nullable
        fields["nullable"]
      end

      def disciminator
        fields["discriminator"]
      end

      def read_only
        fields["readOnly"]
      end

      def write_only
        fields["writeOnly"]
      end

      def xml
        fields["xml"]
      end

      def external_docs
        fields["externalDocs"]
      end

      def example
        fields["example"]
      end

      def deprecated
        fields["deprecated"]
      end

      private

      def required_input_type(input)
        return false unless input.is_a?(Array)
        input.count.positive? && input.map(&:class).uniq == [String]
      end

      def build_referenceable_schema(input, context)
        context.possible_reference(input) do |resolved_input, resolved_context|
          Schema.new(resolved_input, resolved_context)
        end
      end

      def build_schema_array(input, context)
        input.map.with_index do |schema_input, index|
          next_namespace = context.next_namespace(index)
          build_referenceable_schema(schema_input, next_namespace)
        end
      end

      def build_additional_properties(input, context)
        return input unless input.is_a?(Hash)
        build_referenceable_schema(input, context)
      end

      def build_external_docs(input, context)
        ExternalDocumentation.new(input, context)
      end

      def build_properties(input, context)
        Fields::Map.call(input, context) do |next_input, next_context|
          Schema.new(next_input, next_context)
        end
      end
    end
  end
end
