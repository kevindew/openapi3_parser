# frozen_string_literal: true

require "openapi3_parser/node/object"
require "openapi3_parser/nodes/components"

module Openapi3Parser
  module Nodes
    # OpenAPI Root Object
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oasObject
    class Openapi
      include Node::Object

      # @return [String]
      def openapi
        node_data["openapi"]
      end

      # @return [Info]
      def info
        node_data["info"]
      end

      # @return [Nodes::Array] A collection of {Server}[./Server.html] objects
      def servers
        node_data["servers"]
      end

      # @return [Paths]
      def paths
        node_data["paths"]
      end

      # @return [Components, nil]
      def components
        node_data["components"]
      end

      # @return [Nodes::Array] a collection of
      #         {SecurityRequirement}[./SecurityRequirement.html] objects
      def security
        node_data["security"]
      end

      # @return [Nodes::Array] A collection of {Tag}[./Tag.html] objects
      def tags
        node_data["tags"]
      end

      # @return [ExternalDocumentation]
      def external_docs
        node_data["externalDocs"]
      end
    end
  end
end
