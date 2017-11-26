# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class Components
      include Node::Object

      def schemas
        node_data["schemas"]
      end

      def responses
        node_data["responses"]
      end

      def parameters
        node_data["parameters"]
      end

      def examples
        node_data["examples"]
      end

      def request_bodies
        node_data["requestBodies"]
      end

      def headers
        node_data["headers"]
      end

      def security_schemes
        node_data["securitySchemes"]
      end

      def links
        node_data["links"]
      end

      def callbacks
        node_data["callbacks"]
      end
    end
  end
end
