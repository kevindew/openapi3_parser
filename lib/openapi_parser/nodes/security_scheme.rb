# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/oauth_flows"

module OpenapiParser
  module Nodes
    class SecurityScheme
      include Node

      allow_extensions

      field "type", input_type: String, required: true
      field "description", input_type: String
      field "name", input_type: String
      field "in", input_type: String
      field "scheme", input_type: String
      field "bearerFormat", input_type: String
      field "flows",
            input_type: Hash,
            build: ->(i, c) { OauthFlows.new(i, c) }
      field "openIdConnectUrl", input_type: String

      def type
        fields["type"]
      end

      def description
        fields["description"]
      end

      def name
        fields["name"]
      end

      def in
        fields["in"]
      end

      def scheme
        fields["scheme"]
      end

      def bearer_format
        fields["bearerFormat"]
      end

      def flows
        fields["flows"]
      end

      def open_id_connect_url
        fields["openIdConnectUrl"]
      end
    end
  end
end
