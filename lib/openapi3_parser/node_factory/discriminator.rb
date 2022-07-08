# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Discriminator < NodeFactory::Object
      allow_extensions { |context| context.openapi_version >= "3.1" }

      field "propertyName", input_type: String, required: true
      field "mapping", input_type: Hash,
                       validate: :validate_mapping,
                       default: -> { {}.freeze }

      def build_node(data, node_context)
        Node::Discriminator.new(data, node_context)
      end

      private

      def validate_mapping(validatable)
        input = validatable.input
        return if input.empty?

        string_keys = input.keys.map(&:class).uniq == [String]
        string_values = input.values.map(&:class).uniq == [String]
        return if string_keys && string_values

        validatable.add_error("Expected string keys and string values")
      end
    end
  end
end
