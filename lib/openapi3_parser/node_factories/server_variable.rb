# frozen_string_literal: true

require "openapi3_parser/nodes/server_variable"
require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactories
    class ServerVariable
      include NodeFactory::Object

      allow_extensions
      field "enum", input_type: ::Array, validate: :validate_enum
      field "default", input_type: String, required: true
      field "description", input_type: String

      private

      def validate_enum(input)
        return "Expected atleast one value" if input.empty?
        "Expected String values" unless input.map(&:class).uniq == [String]
      end

      def build_object(data, context)
        Nodes::ServerVariable.new(data, context)
      end
    end
  end
end
