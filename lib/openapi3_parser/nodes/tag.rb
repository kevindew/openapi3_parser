# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
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
