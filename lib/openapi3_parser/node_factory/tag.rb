# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/external_documentation"

module Openapi3Parser
  module NodeFactory
    class Tag < NodeFactory::Object
      allow_extensions
      field "name", input_type: String, required: true
      field "description", input_type: String
      field "externalDocs", factory: NodeFactory::ExternalDocumentation

      def build_node(data, node_context)
        Node::Tag.new(data, node_context)
      end
    end
  end
end
