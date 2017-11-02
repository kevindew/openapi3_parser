# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/header"
require "openapi_parser/nodes/media_type"

module OpenapiParser
  module Nodes
    class Response
      include Node

      allow_extensions

      field "description", input_type: String, required: true
      field "headers", input_type: Hash, build: :build_headers_map
      field "content", input_type: Hash, build: :build_content_map

      def description
        fields["description"]
      end

      def headers
        fields["headers"]
      end

      def content
        fields["content"]
      end

      private

      def build_headers_map(i, c)
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          Header.new(resolved_input, resolved_context)
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
