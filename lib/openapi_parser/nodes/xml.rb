# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Xml
      include Node::Object

      def name
        node_data["name"]
      end

      def namespace
        node_data["namespace"]
      end

      def prefix
        node_data["prefix"]
      end

      def attribute
        node_data["attribute"]
      end

      def wrapped
        node_data["wrapped"]
      end
    end
  end
end
