# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/schema"

module OpenapiParser
  module Nodes
    class Components
      include Node

      allow_extensions

      field "schemas",
            input_type: Hash,
            build: :build_schemas_map

      def schemas
        fields["schemas"]
      end

      private

      def build_schemas_map(input, context)
        Fields::Map.call(input, context) do |i, c|
          c.possible_reference(i) do |resolved_input, resolved_context|
            Schema.new(resolved_input, resolved_context)
          end
        end
      end
    end
  end
end
