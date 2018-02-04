# frozen_string_literal: true

require "openapi3_parser/node/server_variable"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factories/array"

module Openapi3Parser
  module NodeFactories
    class ServerVariable
      include NodeFactory::Object

      allow_extensions
      field "enum", factory: :enum_factory, validate: :validate_enum
      field "default", input_type: String, required: true
      field "description", input_type: String

      private

      def enum_factory(context)
        NodeFactories::Array.new(
          context,
          default: nil,
          value_input_type: String
        )
      end

      def validate_enum(input)
        return "Expected atleast one value" if input.empty?
      end

      def build_object(data, context)
        Node::ServerVariable.new(data, context)
      end
    end
  end
end
