# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#mediaTypeObject
    class MediaType < Node::Object
      # @return [Schema, nil]
      def schema
        self["schema"]
      end

      # @return [Any]
      def example
        self["example"]
      end

      # @return [Map<String, Example>, nil]
      def examples
        self["examples"]
      end

      # @return [Map<String, Encoding>]
      def encoding
        self["encoding"]
      end
    end
  end
end
