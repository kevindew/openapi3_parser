# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#exampleObject
    class Example < Node::Object
      # @return [String, nil]
      def summary
        self["summary"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Object]
      def value
        self["value"]
      end

      # @return [String, nil]
      def external_value
        self["externalValue"]
      end
    end
  end
end
