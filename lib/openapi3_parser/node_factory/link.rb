# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Link < NodeFactory::Object
      allow_extensions

      # @todo The link object in OAS is pretty meaty and there's lot of scope
      # for further work here to make use of its functionality

      field "operationRef", input_type: String
      field "operationId", input_type: String
      field "parameters", factory: :parameters_factory
      field "requestBody"
      field "description", input_type: String
      field "server", factory: :server_factory

      mutually_exclusive "operationRef", "operationId", required: true

      private

      def build_object(data, context)
        Node::Link.new(data, context)
      end

      def parameters_factory(context)
        NodeFactory::Map.new(context)
      end

      def server_factory(context)
        NodeFactory::Server.new(context)
      end
    end
  end
end
