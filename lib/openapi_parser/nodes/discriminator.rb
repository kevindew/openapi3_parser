# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Discriminator
      include Node::Object

      def property_name
        node_data["propertyName"]
      end

      def mapping
        node_data["mapping"]
      end
    end
  end
end
