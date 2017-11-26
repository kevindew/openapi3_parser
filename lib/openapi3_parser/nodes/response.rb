# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class Response
      include Node::Object

      def description
        node_data["description"]
      end

      def headers
        node_data["headers"]
      end

      def content
        node_data["content"]
      end

      def links
        node_data["links"]
      end
    end
  end
end
