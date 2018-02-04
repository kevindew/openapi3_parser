# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#mediaTypeObject
    class MediaType < Node::Object
      # @return [Schema, nil]
      def schema
        node_data["schema"]
      end

      # @return [Any]
      def example
        node_data["example"]
      end

      # @return [Map<String, Example>]
      def examples
        node_data["examples"]
      end

      # @return [Map<String, Encoding>]
      def encoding
        node_data["encoding"]
      end
    end
  end
end
