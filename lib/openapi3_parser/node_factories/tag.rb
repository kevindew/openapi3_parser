# frozen_string_literal: true

require "openapi3_parser/node/tag"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factories/external_documentation"

module Openapi3Parser
  module NodeFactories
    class Tag
      include NodeFactory::Object

      allow_extensions
      field "name", input_type: String, required: true
      field "description", input_type: String
      field "externalDocs", factory: NodeFactories::ExternalDocumentation

      private

      def build_object(data, context)
        Node::Tag.new(data, context)
      end
    end
  end
end
