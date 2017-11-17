# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class OauthFlow
      include Node::Object

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
