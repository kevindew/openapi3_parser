# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class Example
      include Node::Object

      def summary
        node_data["summary"]
      end

      def description
        node_data["description"]
      end

      def value
        node_data["value"]
      end

      def external_value
        node_data["externalValue"]
      end
    end
  end
end
