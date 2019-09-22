# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#requestBodyObject
    class RequestBody < Node::Object
      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Map<String, MediaType>]
      def content
        self["content"]
      end

      # @return [Boolean]
      def required?
        self["required"]
      end
    end
  end
end
