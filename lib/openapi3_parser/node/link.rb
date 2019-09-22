# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#linkObject
    class Link < Node::Object
      # @return [String, nil]
      def operation_ref
        self["operationRef"]
      end

      # @return [String, nil]
      def operation_id
        self["operationId"]
      end

      # @return [Map<String, Parameter>]
      def parameters
        self["parameters"]
      end

      # @return [Any]
      def request_body
        self["requestBody"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Server, nil]
      def server
        self["server"]
      end
    end
  end
end
