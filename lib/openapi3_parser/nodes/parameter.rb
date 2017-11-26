# frozen_string_literal: true

require "openapi3_parser/node/object"
require "openapi3_parser/nodes/parameter/parameter_like"

module Openapi3Parser
  module Nodes
    class Parameter
      include Node::Object
      include ParameterLike

      def name
        node_data["name"]
      end

      def in
        node_data["in"]
      end
    end
  end
end
