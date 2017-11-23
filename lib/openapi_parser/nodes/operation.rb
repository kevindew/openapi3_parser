# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Operation
      include Node::Object

      def tags
        node_data["tags"]
      end

      def summary
        node_data["summary"]
      end

      def description
        node_data["description"]
      end

      def external_docs
        node_data["externalDocs"]
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

      def deprecated
        node_data["deprecated"]
      end

      def servers
        node_data["servers"]
      end
    end
  end
end
