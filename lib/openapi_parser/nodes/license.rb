# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class License
      include Node::Object

      def name
        node_data["name"]
      end

      def url
        node_data["url"]
      end
    end
  end
end
