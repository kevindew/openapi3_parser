# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oauthFlowObject
    class OauthFlow < Node::Object
      # @return [String, nil]
      def authorization_url
        self["authorizationUrl"]
      end

      # @return [String, nil]
      def token_url
        self["tokenUrl"]
      end

      # @return [String, nil]
      def refresh_url
        self["refreshUrl"]
      end

      # @return [Map<String, String>]
      def scopes
        self["scopes"]
      end
    end
  end
end
