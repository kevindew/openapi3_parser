# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securitySchemeObject
    class SecurityScheme < Node::Object
      # @return [String, nil]
      def type
        self["type"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [String, nil]
      def name
        self["name"]
      end

      # @return [String, nil]
      def in
        self["in"]
      end

      # @return [String, nil]
      def scheme
        self["scheme"]
      end

      # @return [String, nil]
      def bearer_format
        self["bearerFormat"]
      end

      # @return [OauthFlows, nil]
      def flows
        self["flows"]
      end

      # @return [String, nil]
      def open_id_connect_url
        self["openIdConnectUrl"]
      end
    end
  end
end
