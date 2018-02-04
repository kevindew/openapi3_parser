# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject
    class Components < Node::Object
      # @return [Map<String, Schema>]
      def schemas
        node_data["schemas"]
      end

      # @return [Map<String, Response>]
      def responses
        node_data["responses"]
      end

      # @return [Map<String, Parameter>]
      def parameters
        node_data["parameters"]
      end

      # @return [Map<String, Example>]
      def examples
        node_data["examples"]
      end

      # @return [Map<String, RequestBody>]
      def request_bodies
        node_data["requestBodies"]
      end

      # @return [Map<String, Header>]
      def headers
        node_data["headers"]
      end

      # @return [Map<String, SecurityScheme>]
      def security_schemes
        node_data["securitySchemes"]
      end

      # @return [Map<String, Link>]
      def links
        node_data["links"]
      end

      # @return [Map<String, Callback>]
      def callbacks
        node_data["callbacks"]
      end
    end
  end
end
