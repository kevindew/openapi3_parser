# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#exampleObject
    class Example < Node::Object
      # @return [String, nil]
      def summary
        node_data["summary"]
      end

      # @return [String, nil]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Object]
      def value
        node_data["value"]
      end

      # @return [String, nil]
      def external_value
        node_data["externalValue"]
      end
    end
  end
end
