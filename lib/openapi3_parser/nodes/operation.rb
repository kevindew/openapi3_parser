# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
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

      def responses
        node_data["responses"]
      end

      def callbacks
        node_data["callbacks"]
      end

      def deprecated
        node_data["deprecated"]
      end

      def security
        node_data["security"]
      end

      def servers
        node_data["servers"]
      end
    end
  end
end
