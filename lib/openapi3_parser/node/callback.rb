# frozen_string_literal: true

require "openapi3_parser/node/map"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#callbackObject
    class Callback < Node::Map; end
  end
end
