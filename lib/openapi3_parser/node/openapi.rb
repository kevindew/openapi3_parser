# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # OpenAPI Root Object
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oasObject
    class Openapi < Node::Object
      # @return [String]
      def openapi
        node_data["openapi"]
      end

      # @return [Info]
      def info
        node_data["info"]
      end

      # @return [Node::Array<Server>]
      def servers
        node_data["servers"]
      end

      # @return [Paths]
      def paths
        node_data["paths"]
      end

      # @return [Components]
      def components
        node_data["components"]
      end

      # @return [Node::Array<SecurityRequirement>]
      def security
        node_data["security"]
      end

      # @return [Node::Array<Tag>]
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
