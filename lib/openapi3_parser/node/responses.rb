# frozen_string_literal: true

require "openapi3_parser/node/map"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responsesObject
    class Responses < Node::Map
      # @return [Response]
      def default
        self["default"]
      end
    end
  end
end
