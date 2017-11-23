# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class PathItem
      include Node::Object

      def summary
        node_data["summary"]
      end

      def description
        node_data["description"]
      end

      def servers
        node_data["servers"]
      end

      def parameters
        node_data["parameters"]
      end
    end
  end
end
