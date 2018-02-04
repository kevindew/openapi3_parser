# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject
    class Operation < Node::Object
      # @return [Node::Array<String>]
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

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        node_data["externalDocs"]
      end

      # @return [String, nil]
      def operation_id
        node_data["operationId"]
      end

      # @return [Node::Array<Parameter>]
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

      # @return [Map<String, Callback>]
      def callbacks
        node_data["callbacks"]
      end

      # @return [Boolean]
      def deprecated?
        node_data["deprecated"]
      end

      # @return [Node::Array<SecurityRequirement>]
      def security
        node_data["security"]
      end

      # @return [Node::Array<Server>]
      def servers
        node_data["servers"]
      end
    end
  end
end
