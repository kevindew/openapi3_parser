# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class Link
      include Node::Object

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
