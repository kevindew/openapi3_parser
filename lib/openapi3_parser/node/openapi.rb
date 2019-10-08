# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # OpenAPI Root Object
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oasObject
    class Openapi < Node::Object
      # @return [String]
      def openapi
        self["openapi"]
      end

      # @return [Info]
      def info
        self["info"]
      end

      # @return [Node::Array<Server>]
      def servers
        self["servers"]
      end

      # @return [Paths]
      def paths
        self["paths"]
      end

      # @return [Components]
      def components
        self["components"]
      end

      # @return [Node::Array<SecurityRequirement>]
      def security
        self["security"]
      end

      # @return [Node::Array<Tag>]
      def tags
        self["tags"]
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        self["externalDocs"]
      end
    end
  end
end
