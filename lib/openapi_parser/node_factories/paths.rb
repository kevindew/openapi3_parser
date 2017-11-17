# frozen_string_literal: true

require "openapi_parser/nodes/paths"
require "openapi_parser/node_factory/map"

module OpenapiParser
  module NodeFactories
    class Paths
      include NodeFactory::Map

      private

      def process_input(input, context)
        input.each_with_object({}) do |memo, (key, value)|
          memo[key] = value if extension?(key)
          memo[key] = PathItem.new(context.next_namespace(key))
        end
      end

      def validate(input, context); end

      def build_object(data, context)
        Nodes::Paths.new(data, context)
      end
    end
  end
end
