# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class OauthFlows
      include Node::Object

      def implicit
        node_data["implicit"]
      end

      def password
        node_data["password"]
      end

      def client_credentials
        node_data["clientCredentials"]
      end

      def authorization_code
        node_data["authorizationCode"]
      end
    end
  end
end
