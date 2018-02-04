# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#encodingObject
    class Encoding < Node::Object
      # @return [String, nil]
      def content_type
        node_data["contentType"]
      end

      # @return [Map<String, Header>]
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
