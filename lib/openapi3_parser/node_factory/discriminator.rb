# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Discriminator < NodeFactory::Object
      field "propertyName", input_type: String, required: true
      field "mapping", input_type: Hash,
                       validate: :validate_mapping,
                       default: -> { {}.freeze }

      private

      def build_object(data, context)
        Node::Discriminator.new(data, context)
      end

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
