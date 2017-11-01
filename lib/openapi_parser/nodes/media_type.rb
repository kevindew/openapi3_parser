# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/example"
require "openapi_parser/nodes/encoding"

module OpenapiParser
  module Nodes
    class MediaType
      include Node

      allow_extensions

      field "schema", input_type: Hash, build: :build_schema
      field "example"
      field "examples", input_type: Hash, build: :build_examples_map
      field "encoding", input_type: Hash, build: :build_encoding_map

      def schema
        fields["schema"]
      end

      def example
        fields["example"]
      end

      def examples
        fields["examples"]
      end

      def encoding
        fields["encoding"]
      end

      private

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

      def build_encoding_map(i, c)
        Fields::Map.call(i, c) do |input, context|
          Encoding.new(input, context)
        end
      end
    end
  end
end
