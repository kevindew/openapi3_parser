# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class ExternalDocumentation
      include Node::Object

      def description
        node_data["description"]
      end

      def url
        node_data["url"]
      end
    end
  end
end
