# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/oauth_flow"

module OpenapiParser
  module Nodes
    class OauthFlows
      include Node

      allow_extensions

      field "implicit", input_type: Hash, build: :build_oauth_flow
      field "password", input_type: Hash, build: :build_oauth_flow
      field "clientCredentials", input_type: Hash, build: :build_oauth_flow
      field "authorizationCode", input_type: Hash, build: :build_oauth_flow

      def implicit
        fields["implicit"]
      end

      def password
        fields["password"]
      end

      def client_credentials
        fields["clientCredentials"]
      end

      def authorization_code
        fields["authorizationCode"]
      end

      private

      def build_oauth_flow(input, context)
        OpenAuthFlow.new(input, context)
      end
    end
  end
end
