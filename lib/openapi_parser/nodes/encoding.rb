# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Encoding
      include Node::Object

      def content_type
        node_data["contentType"]
      end

      def headers
        node_data["headers"]
      end

      def style
        node_data["style"]
      end

      def explode
        node_data["explode"]
      end

      def allow_reserved
        node_data["allowReserved"]
      end
    end
  end
end
