# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#encodingObject
    class Encoding < Node::Object
      # @return [String, nil]
      def content_type
        self["contentType"]
      end

      # @return [Map<String, Header>]
      def headers
        self["headers"]
      end

      # @return [String, nil]
      def style
        self["style"]
      end

      # @return [Boolean]
      def explode?
        self["explode"]
      end

      # @return [Boolean]
      def allow_reserved?
        self["allowReserved"]
      end
    end
  end
end
