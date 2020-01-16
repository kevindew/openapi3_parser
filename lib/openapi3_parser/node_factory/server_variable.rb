# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class ServerVariable < NodeFactory::Object
      allow_extensions
      field "enum", factory: :enum_factory
      field "default", input_type: String, required: true
      field "description", input_type: String

      private

      def enum_factory(context)
        NodeFactory::Array.new(
          context,
          default: nil,
          value_input_type: String,
          validate: lambda do |validatable|
            return if validatable.input.any?

            validatable.add_error("Expected atleast one value")
          end
        )
      end

      def build_object(data, context)
        Node::ServerVariable.new(data, context)
      end
    end
  end
end
