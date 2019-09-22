# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responseObject
    class Response < Node::Object
      # @return [String]
      def description
        self["description"]
      end

      # @return [String]
      def description_html
        render_markdown(description)
      end

      # @return [Map<String, Header>]
      def headers
        self["headers"]
      end

      # @return [Map<String, MediaType>]
      def content
        self["content"]
      end

      # @return [Map<String, Link>]
      def links
        self["links"]
      end
    end
  end
end
