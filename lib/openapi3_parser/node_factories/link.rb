# frozen_string_literal: true

require "openapi3_parser/nodes/license"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/node_factories/server"

module Openapi3Parser
  module NodeFactories
    class Link
      include NodeFactory::Object

      allow_extensions

      # @todo The link object in OAS is pretty meaty and there's lot of scope
      # for further work here to make use of it's funcationality

      field "operationRef", input_type: String
      field "operationId", input_type: String
      field "parameters", factory: :parameters_factory
      field "requestBody"
      field "description", input_type: String
      field "server", factory: :server_factory

      private

      def build_object(data, context)
        Nodes::Link.new(data, context)
      end

      def parameters_factory(context)
        NodeFactories::Map.new(context)
      end

      def server_factory(context)
        NodeFactories::Server.new(context)
      end
    end
  end
end
