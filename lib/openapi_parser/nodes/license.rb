# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class Example
      include Node

      allow_extensions

      field "summary", input_type: String
      field "description", input_type: String
      field "value"
      field "externalValue", input_type: String

      def summary
        fields["summary"]
      end

      def description
        fields["description"]
      end

      def value
        fields["value"]
      end

      def external_value
        fields["externalValue"]
      end
    end
  end
end
