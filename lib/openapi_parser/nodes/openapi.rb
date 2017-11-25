# frozen_string_literal: true

require "openapi_parser/node/object"
require "openapi_parser/nodes/components"

module OpenapiParser
  module Nodes
    class Openapi
      include Node::Object

      def openapi
        node_data["openapi"]
      end

      def info
        node_data["info"]
      end

      def servers
        node_data["servers"]
      end

      def paths
        node_data["paths"]
      end

      def components
        node_data["components"]
      end

      def security
        node_data["security"]
      end

      def tags
        node_data["tags"]
      end

      def external_docs
        node_data["externalDocs"]
      end
    end
  end
end
