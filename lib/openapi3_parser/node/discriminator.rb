# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#discriminatorObject
    class Discriminator < Node::Object
      # @return [String]
      def property_name
        self["propertyName"]
      end

      # @return [Map<String, String>]
      def mapping
        self["mapping"]
      end
    end
  end
end
