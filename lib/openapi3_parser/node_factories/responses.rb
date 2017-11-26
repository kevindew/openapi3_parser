# frozen_string_literal: true

require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/nodes/responses"
require "openapi3_parser/node_factories/response"

module Openapi3Parser
  module NodeFactories
    class Responses
      include NodeFactory::Map

      private

      def process_input(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value if extension?(key)
          memo[key] = child_factory(context.next_namespace(key))
        end
      end

      def child_factory(child_context)
        NodeFactory::OptionalReference.new(NodeFactories::Response)
                                      .call(child_context)
      end

      def build_map(data, context)
        Nodes::Responses.new(data, context)
      end
    end
  end
end
