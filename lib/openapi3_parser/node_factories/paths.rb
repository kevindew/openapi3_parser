# frozen_string_literal: true

require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factories/path_item"
require "openapi3_parser/nodes/paths"

module Openapi3Parser
  module NodeFactories
    class Paths
      include NodeFactory::Map

      private

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value if extension?(key)
          next_context = Context.next_field(context, key)
          memo[key] = child_factory(next_context)
        end
      end

      def child_factory(child_context)
        NodeFactory::OptionalReference.new(NodeFactories::PathItem)
                                      .call(child_context)
      end

      def build_map(data, context)
        Nodes::Paths.new(data, context)
      end
    end
  end
end
