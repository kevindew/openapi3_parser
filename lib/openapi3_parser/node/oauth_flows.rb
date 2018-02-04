# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oauthFlowsObject
    class OauthFlows < Node::Object
      # @return [OauthFlow, nil]
      def implicit
        node_data["implicit"]
      end

      # @return [OauthFlow, nil]
      def password
        node_data["password"]
      end

      # @return [OauthFlow, nil]
      def client_credentials
        node_data["clientCredentials"]
      end

      # @return [OauthFlow, nil]
      def authorization_code
        node_data["authorizationCode"]
      end
    end
  end
end
