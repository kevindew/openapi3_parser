# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/header"

module OpenapiParser
  module Nodes
    class Encoding
      include Node

      allow_extensions

      field "contentType", input_type: String
      field "headers", input_type: Hash, build: :build_headers_map
      field "style", input_type: String
      field "explode", input_type: :boolean, default: true
      field "allowReserved", input_type: :boolean, default: false

      def content_type
        fields["contentType"]
      end

      def headers
        fields["headers"]
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

      private

      def build_headers_map(input, context)
        Fields::Map.call(input, context) do |i, c|
          c.possible_reference(i) do |resolved_input, resolved_context|
            Header.new(resolved_input, resolved_context)
          end
        end
      end
    end
  end
end
