# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Server
      include Node::Object

      # @TODO there's scope for an interpolated_url method which can use the
      # values from variables
      def url
        node_data["url"]
      end

      def description
        node_data["description"]
      end

      def variables
        node_data["variables"]
      end
    end
  end
end
