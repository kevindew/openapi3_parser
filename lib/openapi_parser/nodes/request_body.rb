# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/media_type"
require "openapi_parser/fields/map"

module OpenapiParser
  module Nodes
    class RequestBody
      include Node

      allow_extensions

      field "description", input_type: String
      field "content", input_type: Hash,
                       required: true,
                       build: :build_content_map
      field "required", input_type: :boolean, default: false

      def description
        fields["description"]
      end

      def content
        fields["content"]
      end

      def required
        fields["required"]
      end

      private

      def build_content_map
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          MediaType.new(resolved_input, resolved_context)
        end
      end
    end
  end
end
