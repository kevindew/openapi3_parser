# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Example
      include Node::Object

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
