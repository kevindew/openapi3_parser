# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class OauthFlow
      include Node

      allow_extensions

      field "authorizationUrl", input_type: String, required: true
      field "tokenUrl", input_type: String, required: true
      field "refreshUrl", input_type: String
      field "scopes", input_type: Hash, required: true

      def authorization_url
        fields["authorizationUrl"]
      end

      def token_url
        fields["tokenUrl"]
      end

      def refresh_url
        fields["refreshUrl"]
      end

      def scopes
        fields["scopes"]
      end
    end
  end
end
