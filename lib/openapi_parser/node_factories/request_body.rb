# frozen_string_literal: true

require "openapi_parser/nodes/request_body"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factories/media_type"
require "openapi_parser/node_factories/map"

module OpenapiParser
  module NodeFactories
    class RequestBody
      include NodeFactory::Object

      allow_extensions
      field "description", input_type: String
      field "content", factory: :content_factory, required: true
      field "required", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Nodes::RequestBody.new(data, context)
      end

      def content_factory(context)
        NodeFactories::Map.new(
          context, value_factory: NodeFactories::MediaType
        )
      end
    end
  end
end
