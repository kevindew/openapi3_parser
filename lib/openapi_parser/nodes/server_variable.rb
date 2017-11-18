# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class ServerVariable
      include Node::Object

      def enum
        node_data["enum"]
      end

      def default
        node_data["default"]
      end

      def description
        node_data["description"]
      end
    end
  end
end
