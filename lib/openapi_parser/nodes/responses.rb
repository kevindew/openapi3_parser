# frozen_string_literal: true

require "openapi_parser/node/map"

module OpenapiParser
  module Nodes
    class Responses
      include Node::Map

      def default
        node_data["default"]
      end
    end
  end
end
