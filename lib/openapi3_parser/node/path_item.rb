# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathItemObject
    class PathItem < Node::Object
      # @return [String, nil]
      def summary
        self["summary"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Operation, nil]
      def get
        self["get"]
      end

      # @return [Operation, nil]
      def put
        self["put"]
      end

      # @return [Operation, nil]
      def post
        self["post"]
      end

      # @return [Operation, nil]
      def delete
        self["delete"]
      end

      # @return [Operation, nil]
      def options
        self["options"]
      end

      # @return [Operation, nil]
      def head
        self["head"]
      end

      # @return [Operation, nil]
      def patch
        self["patch"]
      end

      # @return [Operation, nil]
      def trace
        self["trace"]
      end

      # @return [Node::Array<Server>]
      def servers
        self["servers"]
      end

      # Whether this object uses it's own defined servers instead of falling
      # back to the root ones.
      #
      # @return [Boolean]
      def alternative_servers?
        servers != node_context.document.root.servers
      end

      # @return [Node::Array<Parameter>]
      def parameters
        self["parameters"]
      end
    end
  end
end
