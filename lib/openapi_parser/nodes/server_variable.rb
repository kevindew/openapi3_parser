# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class ServerVariable
      include Node

      allow_extensions

      field "enum", input_type: :enum_input_type
      field "default", input_type: String, required: true
      field "description", input_type: String

      def default
        fields["default"]
      end

      def description
        fields["description"]
      end

      def enum
        fields["enum"]
      end

      private

      def enum_input_type(input)
        input.is_a?(Array) && input.map(&:class).uniq == [String]
      end
    end
  end
end
