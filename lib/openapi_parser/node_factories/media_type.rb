# frozen_string_literal: true

require "openapi_parser/nodes/media_type"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/map"
require "openapi_parser/node_factories/schema"
require "openapi_parser/node_factories/example"
require "openapi_parser/node_factories/encoding"

module OpenapiParser
  module NodeFactories
    class MediaType
      include NodeFactory::Object

      allow_extensions
      field "schema", factory: :schema_factory
      field "example"
      field "examples", factory: :examples_factory
      field "encoding", factory: :encoding_factory

      private

      def build_object(data, context)
        Nodes::MediaType.new(data, context)
      end

      def schema_factory(context)
        factory = NodeFactories::Schema
        NodeFactory::OptionalReference.new(factory).call(context)
      end

      def examples_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Example)
        NodeFactories::Map.new(context, value_factory: factory)
      end

      def encoding_factory(context)
        factory = NodeFactories::Encoding
        NodeFactories::Map.new(context, value_factory: factory)
      end
    end
  end
end
