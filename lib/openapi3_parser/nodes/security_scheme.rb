# frozen_string_literal: true

require "openapi3_parser/node/object"
require "openapi3_parser/nodes/oauth_flows"

module Openapi3Parser
  module Nodes
    class SecurityScheme
      include Node::Object

      def type
        node_data["type"]
      end

      def description
        node_data["description"]
      end

      def name
        node_data["name"]
      end

      def in
        node_data["in"]
      end

      def scheme
        node_data["scheme"]
      end

      def bearer_format
        node_data["bearerFormat"]
      end

      def flows
        node_data["flows"]
      end

      def open_id_connect_url
        node_data["openIdConnectUrl"]
      end
    end
  end
end
