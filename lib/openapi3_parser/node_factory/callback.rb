# frozen_string_literal: true

require "openapi3_parser/node_factory/map"

module Openapi3Parser
  module NodeFactory
    class Callback < NodeFactory::Map
      def initialize(context)
        super(context,
              allow_extensions: true,
              value_factory: NodeFactory::PathItem)
      end

      private

      def build_node(data, node_context)
        Node::Callback.new(data, node_context)
      end
    end
  end
end
