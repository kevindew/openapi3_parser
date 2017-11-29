# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject
    class Components
      include Node::Object

      # @return [Map] a map of String: {Schema}[../Schema.html] objects
      def schemas
        node_data["schemas"]
      end

      # @return [Map] a map of String: {Response}[./Response.html] objects
      def responses
        node_data["responses"]
      end

      # @return [Map] a map of String: {Parameter}[./Parameter.html] objects
      def parameters
        node_data["parameters"]
      end

      # @return [Map] a map of String: {Example}[../Example.html] objects
      def examples
        node_data["examples"]
      end

      # @return [Map] a map of String: {RequestBody}[./RequestBody.html]
      #         objects
      def request_bodies
        node_data["requestBodies"]
      end

      # @return [Map] a map of String: {Header}[./Header.html] objects
      def headers
        node_data["headers"]
      end

      # @return [Map] a map of String: {SecurityScheme}[./SecurityScheme.html]
      #         objects
      def security_schemes
        node_data["securitySchemes"]
      end

      # @return [Map] a map of String: {Link}[./Link.html] objects
      def links
        node_data["links"]
      end

      # @return [Map] a map of String: {Callback}[./Callback.html] objects
      def callbacks
        node_data["callbacks"]
      end
    end
  end
end
