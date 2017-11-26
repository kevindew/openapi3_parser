# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class ExternalDocumentation
      include Node::Object

      def description
        node_data["description"]
      end

      def url
        node_data["url"]
      end
    end
  end
end
