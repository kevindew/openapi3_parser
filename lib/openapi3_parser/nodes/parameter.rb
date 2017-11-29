# frozen_string_literal: true

require "openapi3_parser/node/object"
require "openapi3_parser/nodes/parameter/parameter_like"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#parameterObject
    class Parameter
      include Node::Object
      include ParameterLike

      # @return [String]
      def name
        node_data["name"]
      end

      # @return [String]
      def in
        node_data["in"]
      end
    end
  end
end
