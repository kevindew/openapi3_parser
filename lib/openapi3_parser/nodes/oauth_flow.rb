# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class OauthFlow
      include Node::Object

      def authorization_url
        node_data["authorizationUrl"]
      end

      def token_url
        node_data["tokenUrl"]
      end

      def refresh_url
        node_data["refreshUrl"]
      end

      def scopes
        node_data["scopes"]
      end
    end
  end
end
