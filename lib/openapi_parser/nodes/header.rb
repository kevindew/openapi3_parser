# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/external_documentation"

module OpenapiParser
  module Nodes
    class Header
      include Node

      allow_extensions

      field "name", input_type: String, required: true
      field "description", input_type: String
      field "externalDocs",
            input_type: Hash,
            build: :build_external_docs

      def name
        fields["name"]
      end

      def description
        fields["description"]
      end

      def external_docs
        fields["externalDocs"]
      end

      private

      def build_external_docs(input, context)
        ExternalDocumentation.new(input, context)
      end
    end
  end
end
