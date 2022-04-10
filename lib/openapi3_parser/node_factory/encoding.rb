# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Encoding < NodeFactory::Object
      allow_extensions

      field "contentType", input_type: String
      field "headers", factory: :headers_factory
      field "style", input_type: String
      field "explode", input_type: :boolean, default: :default_explode
      field "allowReserved", input_type: :boolean, default: false

      def build_node(data, node_context)
        Node::Encoding.new(data, node_context)
      end

      private

      def headers_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Header)
        NodeFactory::Map.new(context, value_factory: factory)
      end

      def default_explode
        context.input["style"] == "form"
      end
    end
  end
end
