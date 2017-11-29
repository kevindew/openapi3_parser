# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject
    class Operation
      include Node::Object

      # @return [Nodes::Array] a collection of String objects
      def tags
        node_data["tags"]
      end

      # @return [String, nil]
      def summary
        node_data["summary"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        node_data["externalDocs"]
      end

      # @return [String, nil]
      def operation_id
        node_data["operationId"]
      end

      # @return [Nodes::Array] a collection of {Parameter}[./Parameter.html]
      #         objects
      def parameters
        node_data["parameters"]
      end

      # @return [RequestBody, nil]
      def request_body
        node_data["requestBody"]
      end

      # @return [Responses]
      def responses
        node_data["responses"]
      end

      # @return [Map] a collection of String: {Callback}[./Callback.html]
      #         objects
      def callbacks
        node_data["callbacks"]
      end

      # @return [Boolean]
      def deprecated?
        node_data["deprecated"]
      end

      # @return [Nodes::Array] a collection of
      #         {SecurityRequirement}[./SecurityRequirement.html] objects
      def security
        node_data["security"]
      end

      # @return [Nodes::Array] a collection of {Server}[./Server.html] objects
      def servers
        node_data["servers"]
      end
    end
  end
end
