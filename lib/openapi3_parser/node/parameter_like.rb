# frozen_string_literal: true

module Openapi3Parser
  module Node
    # This contains methods that are shared between nodes that act like a
    # Parameter, at the time of writing this was {Header}[../Header.html]
    # and {Parameter}[../Paramater.html]
    module ParameterLike
      # @return [String]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [Boolean]
      def required?
        self["required"]
      end

      # @return [Boolean]
      def deprecated?
        self["deprecated"]
      end

      # @return [Boolean]
      def allow_empty_value?
        self["allowEmptyValue"]
      end

      # @return [String, nil]
      def style
        self["style"]
      end

      # @return [Boolean]
      def explode?
        self["explode"]
      end

      # @return [Boolean]
      def allow_reserved?
        self["allowReserved"]
      end

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

      # @return [Map<String, MediaType>, nil]
      def content
        self["content"]
      end
    end
  end
end
