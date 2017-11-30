# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathItemObject
    class PathItem
      include Node::Object

      # @return [String, nil]
      def summary
        node_data["summary"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [Operation, nil]
      def get
        node_data["get"]
      end

      # @return [Operation, nil]
      def put
        node_data["put"]
      end

      # @return [Operation, nil]
      def post
        node_data["post"]
      end

      # @return [Operation, nil]
      def delete
        node_data["delete"]
      end

      # @return [Operation, nil]
      def options
        node_data["options"]
      end

      # @return [Operation, nil]
      def head
        node_data["head"]
      end

      # @return [Operation, nil]
      def patch
        node_data["patch"]
      end

      # @return [Operation, nil]
      def trace
        node_data["trace"]
      end

      # @return [Nodes::Array] a collection of {Server}[./Server.html] objects
      def servers
        node_data["servers"]
      end

      # @return [Nodes::Array] a collection of {Parameter}[./Parameter.html]
      #         objects
      def parameters
        node_data["parameters"]
      end
    end
  end
end
