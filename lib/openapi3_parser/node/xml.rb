# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#xmlObject
    class Xml < Node::Object
      # @return [String, nil]
      def name
        node_data["name"]
      end

      # @return [String, nil]
      def namespace
        node_data["namespace"]
      end

      # @return [String, nil]
      def prefix
        node_data["prefix"]
      end

      # @return [Boolean]
      def attribute?
        node_data["attribute"]
      end

      # @return [Boolean]
      def wrapped?
        node_data["wrapped"]
      end
    end
  end
end
