# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Tag
      include Node::Object

      def name
        node_data["name"]
      end

      def description
        node_data["description"]
      end

      def external_docs
        node_data["externalDocs"]
      end
    end
  end
end
