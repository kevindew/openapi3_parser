# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class Discriminator
      include Node

      field "propertyName", input_type: String, required: true
      field "mapping",
            input_type: :mapping_input_type,
            default: -> { {}.freeze }

      def property_name
        fields["propertyName"]
      end

      def mapping
        fields["mapping"]
      end

      private

      def mapping_input_type(input)
        return false unless input.is_a?(Hash)
        return true if input.empty?
        string_keys = input.keys.map(&:class).uniq == [String]
        string_values = input.values.map(&:class).uniq == [String]
        string_keys && string_values
      end
    end
  end
end
