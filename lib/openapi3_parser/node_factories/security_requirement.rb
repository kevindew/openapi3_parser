# frozen_string_literal: true

require "openapi3_parser/nodes/security_requirement"
require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factories/array"

module Openapi3Parser
  module NodeFactories
    class SecurityRequirement
      include NodeFactory::Map

      private

      def process_input(input)
        input.keys.each_with_object({}) do |key, memo|
          next_context = Context.next_field(context, key)
          memo[key] = NodeFactories::Array.new(next_context)
        end
      end

      def build_map(data, context)
        Nodes::SecurityRequirement.new(data, context)
      end
    end
  end
end
