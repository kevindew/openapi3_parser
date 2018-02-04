# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#linkObject
    class Link < Node::Object
      # @return [String, nil]
      def operation_ref
        node_data["operationRef"]
      end

      # @return [String, nil]
      def operation_id
        node_data["operationId"]
      end

      # @return [Map<String, Parameter>]
      def parameters
        node_data["parameters"]
      end

      # @return [Any]
      def request_body
        node_data["requestBody"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Server, nil]
      def server
        node_data["server"]
      end
    end
  end
end
