# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#xmlObject
    class Xml < Node::Object
      # @return [String, nil]
      def name
        self["name"]
      end

      # @return [String, nil]
      def namespace
        self["namespace"]
      end

      # @return [String, nil]
      def prefix
        self["prefix"]
      end

      # @return [Boolean]
      def attribute?
        self["attribute"]
      end

      # @return [Boolean]
      def wrapped?
        self["wrapped"]
      end
    end
  end
end
