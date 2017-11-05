# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/example"
require "openapi_parser/nodes/media_type"

module OpenapiParser
  module Nodes
    class Parameter
      include Node

      allow_extensions

      field "name", input_type: String, required: true
      field "in", input_type: String, required: true
      field "description", input_type: String
      field "required", input_type: :boolean, default: false
      field "deprecated", input_type: :boolean, default: false
      field "allowEmptyValue", input_type: :boolean, default: false

      field "style", input_type: String, default: :default_style
      field "explode", input_type: :boolean, default: :default_explode
      field "allowReserved", input_type: :boolean, default: false
      field "schema", input_type: Hash, build: :build_schema
      field "example"
      field "examples", input_type: Hash, build: :build_examples_map

      field "content", input_type: Hash, build: :build_content_map

      def name
        fields["name"]
      end

      def in
        fields["in"]
      end

      def description
        fields["description"]
      end

      def required
        fields["required"]
      end

      def deprecated
        fields["deprecated"]
      end

      def allow_empty_value
        fields["allowEmptyValue"]
      end

      def style
        fields["style"]
      end

      def explode
        fields["explode"]
      end

      def allow_reserved
        fields["allowReserved"]
      end

      def schema
        fields["schema"]
      end

      def example
        fields["example"]
      end

      def examples
        fields["examples"]
      end

      def content
        fields["content"]
      end

      private

      def default_style
        return "simple" if %w[path header].include?(input["in"])
        "form"
      end

      def default_explode
        (input["style"] || default_style) == "form"
      end

      def build_schema(input, context)
        context.possible_reference(input) do |resolved_input, resolved_context|
          Schema.new(resolved_input, resolved_context)
        end
      end

      def build_examples_map(i, c)
        Fields::Map.reference_input(i, c) do |input, context|
          Example.new(input, context)
        end
      end

      def build_content_map(i, c)
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          MediaType.new(resolved_input, resolved_context)
        end
      end
    end
  end
end
