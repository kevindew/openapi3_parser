# frozen_string_literal: true

require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factories/path_item"
require "openapi3_parser/nodes/callback"

module Openapi3Parser
  module NodeFactories
    class Callback
      include NodeFactory::Map

      private

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value if extension?(key)
          next_context = Context.next_field(context, key)
          memo[key] = NodeFactories::PathItem.new(next_context)
        end
      end

      def build_map(data, context)
        Nodes::Callback.new(data, context)
      end
    end
  end
end
