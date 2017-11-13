# frozen_string_literal: true

require "openapi_parser/nodes/paths"
require "openapi_parser/node/factory/map"
require "openapi_parser/error"

module OpenapiParser
  module Nodes
    class Paths
      class Factory
        include Node::Factory::Map

        private

        def process_input(input, context)
          input.each_with_object({}) do |memo, (key, value)|
            memo[key] = value if extension?(key)
            memo[key] = PathItem::Factory.new(context.next_namespace(key))
          end
        end

        def validate(input, context)
        end

        def build_object(data, context)
          Paths.new(data, context)
        end
      end
    end
  end
end
