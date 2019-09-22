# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oauthFlowsObject
    class OauthFlows < Node::Object
      # @return [OauthFlow, nil]
      def implicit
        self["implicit"]
      end

      # @return [OauthFlow, nil]
      def password
        self["password"]
      end

      # @return [OauthFlow, nil]
      def client_credentials
        self["clientCredentials"]
      end

      # @return [OauthFlow, nil]
      def authorization_code
        self["authorizationCode"]
      end
    end
  end
end
