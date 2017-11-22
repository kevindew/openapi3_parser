# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class RequestBody
      include Node::Object

      def description
        node_data["description"]
      end

      def content
        node_data["content"]
      end

      def required
        node_data["required"]
      end
    end
  end
end
