# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject
    class Components < Node::Object
      # @return [Map<String, Schema>]
      def schemas
        self["schemas"]
      end

      # @return [Map<String, Response>]
      def responses
        self["responses"]
      end

      # @return [Map<String, Parameter>]
      def parameters
        self["parameters"]
      end

      # @return [Map<String, Example>]
      def examples
        self["examples"]
      end

      # @return [Map<String, RequestBody>]
      def request_bodies
        self["requestBodies"]
      end

      # @return [Map<String, Header>]
      def headers
        self["headers"]
      end

      # @return [Map<String, SecurityScheme>]
      def security_schemes
        self["securitySchemes"]
      end

      # @return [Map<String, Link>]
      def links
        self["links"]
      end

      # @return [Map<String, Callback>]
      def callbacks
        self["callbacks"]
      end
    end
  end
end
