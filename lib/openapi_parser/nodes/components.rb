# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/referenceable_map"
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

      def build_schemas_map(input, document, namespace)
        Fields::ReferenceableMap.call(
          input,
          document,
          namespace
        ) do |new_input, new_document, new_namespace|
          Schema.new(new_input, new_document, new_namespace)
        end
      end
    end
  end
end
