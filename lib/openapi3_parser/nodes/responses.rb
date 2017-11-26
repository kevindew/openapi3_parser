# frozen_string_literal: true

require "openapi3_parser/node/map"

module Openapi3Parser
  module Nodes
    class Responses
      include Node::Map

      def default
        node_data["default"]
      end
    end
  end
end
