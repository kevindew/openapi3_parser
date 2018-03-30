# frozen_string_literal: true

module Openapi3Parser
  module Node
    # This contains methods that are shared between nodes that act like a
    # Parameter, at the time of writing this was {Header}[../Header.html]
    # and {Parameter}[../Paramater.html]
    module ParameterLike
      # @return [String]
      def description
        node_data["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Boolean]
      def required?
        node_data["required"]
      end

      # @return [Boolean]
      def deprecated?
        node_data["deprecated"]
      end

      # @return [Boolean]
      def allow_empty_value?
        node_data["allowEmptyValue"]
      end

      # @return [String, nil]
      def style
        node_data["style"]
      end

      # @return [Boolean]
      def explode?
        node_data["explode"]
      end

      # @return [Boolean]
      def allow_reserved?
        node_data["allowReserved"]
      end

      # @return [Schema, nil]
      def schema
        node_data["schema"]
      end

      # @return [Any]
      def example
        node_data["example"]
      end

      # @return [Map<String, Example>, nil]
      def examples
        node_data["examples"]
      end

      # @return [Map<String, MediaType>, nil]
      def content
        node_data["content"]
      end
    end
  end
end
