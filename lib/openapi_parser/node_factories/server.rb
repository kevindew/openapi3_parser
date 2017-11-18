# frozen_string_literal: true

require "openapi_parser/nodes/server"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factories/server_variable"
require "openapi_parser/node_factories/map"

module OpenapiParser
  module NodeFactories
    class Server
      include NodeFactory::Object

      allow_extensions
      field "url", input_type: String, required: true
      field "description", input_type: String
      field "variables", factory: :variables_factory

      private

      def build_object(data, context)
        Nodes::Server.new(data, context)
      end

      def variables_factory(context)
        NodeFactories::Map.new(
          context,
          value_factory: NodeFactories::ServerVariable
        )
      end
    end
  end
end
