# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#tagObject
    class Tag < Node::Object
      # @return [String]
      def name
        node_data["name"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [ExternalDocumentation, nil]
      def external_docs
        node_data["externalDocs"]
      end
    end
  end
end
