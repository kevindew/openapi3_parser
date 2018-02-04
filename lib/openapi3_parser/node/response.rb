# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responseObject
    class Response < Node::Object
      # @return [String]
      def description
        node_data["description"]
      end

      # @return [String]
      def description_html
        render_markdown(description)
      end

      # @return [Map<String, Header>]
      def headers
        node_data["headers"]
      end

      # @return [Map<String, MediaType>]
      def content
        node_data["content"]
      end

      # @return [Map<String, Link>]
      def links
        node_data["links"]
      end
    end
  end
end
