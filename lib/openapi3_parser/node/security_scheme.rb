# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securitySchemeObject
    class SecurityScheme < Node::Object
      # @return [String, nil]
      def type
        node_data["type"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [String, nil]
      def name
        node_data["name"]
      end

      # @return [String, nil]
      def in
        node_data["in"]
      end

      # @return [String, nil]
      def scheme
        node_data["scheme"]
      end

      # @return [String, nil]
      def bearer_format
        node_data["bearerFormat"]
      end

      # @return [OauthFlows, nil]
      def flows
        node_data["flows"]
      end

      # @return [String, nil]
      def open_id_connect_url
        node_data["openIdConnectUrl"]
      end
    end
  end
end
