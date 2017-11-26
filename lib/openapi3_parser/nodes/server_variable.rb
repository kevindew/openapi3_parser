# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
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
