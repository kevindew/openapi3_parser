# frozen_string_literal: true

require "openapi3_parser/nodes/example"
require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactories
    class Example
      include NodeFactory::Object

      allow_extensions

      field "summary", input_type: String
      field "description", input_type: String
      field "value"
      field "externalValue", input_type: String

      private

      def build_object(data, context)
        Nodes::Example.new(data, context)
      end
    end
  end
end
