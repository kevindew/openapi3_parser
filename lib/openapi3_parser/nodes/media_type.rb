# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#mediaTypeObject
    class MediaType
      include Node::Object

      # @return [Schema, nil]
      def schema
        node_data["schema"]
      end

      # @return [Any]
      def example
        node_data["example"]
      end

      # @return [Map] a map of String: {Example}[./Example.html] objects
      def examples
        node_data["examples"]
      end

      # @return [Map] a map of String: {Encoding}[./Encoding.html] objects
      def encoding
        node_data["encoding"]
      end
    end
  end
end
