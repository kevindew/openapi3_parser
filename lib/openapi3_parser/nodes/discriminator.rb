# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
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
