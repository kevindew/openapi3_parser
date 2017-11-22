# frozen_string_literal: true

require "openapi_parser/nodes/response"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/map"
require "openapi_parser/node_factories/header"
require "openapi_parser/node_factories/media_type"
require "openapi_parser/node_factories/link"

module OpenapiParser
  module NodeFactories
    class Response
      include NodeFactory::Object

      allow_extensions
      field "description", input_type: String, required: true
      field "headers", factory: :headers_factory
      field "content", factory: :content_factory
      field "links", factory: :links_factory

      private

      def build_object(data, context)
        Nodes::Response.new(data, context)
      end

      def headers_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Header)
        NodeFactories::Map.new(context, value_factory: factory)
      end

      def content_factory(context)
        NodeFactories::Map.new(
          context, value_factory: NodeFactories::MediaType
        )
      end

      def links_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Link)
        NodeFactories::Map.new(context, value_factory: factory)
      end
    end
  end
end
