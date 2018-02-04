# frozen_string_literal: true

require "openapi3_parser/node/encoding"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/node_factories/header"

module Openapi3Parser
  module NodeFactories
    class Encoding
      include NodeFactory::Object

      allow_extensions

      field "contentType", input_type: String
      field "headers", factory: :headers_factory
      field "style", input_type: String
      field "explode", input_type: :boolean, default: true
      field "allowReserved", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Node::Encoding.new(data, context)
      end

      def headers_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Header)
        NodeFactories::Map.new(context, value_factory: factory)
      end
    end
  end
end
