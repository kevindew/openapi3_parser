# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/server"
require "openapi_parser/fields/map"

module OpenapiParser
  module Nodes
    class Link
      include Node

      allow_extensions

      # @TODO The link object in OAS is pretty meaty and there's lot of scope
      # for further work here to make use of it's funcationality
      field "operationRef", input_type: String
      field "operationId", input_type: String
      field "parameters",
            input_type: Hash,
            build: ->(input, context) { Fields::Map.call(input, context) }
      field "requestBody"
      field "description", input_type: String
      field "server",
            input_type: Hash,
            build: ->(input, context) { Server.new(input, context) }

      def operation_ref
        fields["operationRef"]
      end

      def operation_id
        fields["operationId"]
      end

      def parameters
        fields["parameters"]
      end

      def request_body
        fields["requestBody"]
      end

      def description
        fields["description"]
      end

      def server
        fields["server"]
      end
    end
  end
end
