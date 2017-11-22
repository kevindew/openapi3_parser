# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Link
      include Node::Object

      # allow_extensions
      #
      # # @TODO The link object in OAS is pretty meaty and there's lot of scope
      # # for further work here to make use of it's funcationality
      # field "operationRef", input_type: String
      # field "operationId", input_type: String
      # field "parameters",
      #       input_type: Hash,
      #       build: ->(input, context) { Fields::Map.call(input, context) }
      # field "requestBody"
      # field "description", input_type: String
      # field "server",
      #       input_type: Hash,
      #       build: ->(input, context) { Server.new(input, context) }
      #
      def operation_ref
        node_data["operationRef"]
      end

      def operation_id
        node_data["operationId"]
      end

      def parameters
        node_data["parameters"]
      end

      def request_body
        node_data["requestBody"]
      end

      def description
        node_data["description"]
      end

      def server
        node_data["server"]
      end
    end
  end
end
