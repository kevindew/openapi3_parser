# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#encodingObject
    class Encoding
      include Node::Object

      # @return [String, nil]
      def content_type
        node_data["contentType"]
      end

      # @return [Map] a map of String: {Header}[./Header.html] objects
      def headers
        node_data["headers"]
      end

      # @return [String, nil]
      def style
        node_data["style"]
      end

      # @return [Boolean]
      def explode?
        node_data["explode"]
      end

      # @return [Boolean]
      def allow_reserved?
        node_data["allowReserved"]
      end
    end
  end
end
