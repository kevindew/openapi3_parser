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

      def get
        node_data["get"]
      end

      def put
        node_data["put"]
      end

      def post
        node_data["post"]
      end

      def delete
        node_data["delete"]
      end

      def options
        node_data["options"]
      end

      def head
        node_data["head"]
      end

      def patch
        node_data["patch"]
      end

      def trace
        node_data["trace"]
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
