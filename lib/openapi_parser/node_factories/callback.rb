# frozen_string_literal: true

require "openapi_parser/node_factory/map"
require "openapi_parser/node_factories/path_item"
require "openapi_parser/nodes/callback"

module OpenapiParser
  module NodeFactories
    class Callback
      include NodeFactory::Map

      private

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value if extension?(key)
          memo[key] = NodeFactories::PathItem.new(context.next_namespace(key))
        end
      end

      def build_map(data, context)
        Nodes::Callback.new(data, context)
      end
    end
  end
end
