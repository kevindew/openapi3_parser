# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class ServerVariable
      include Node::Object

      def enum
        fields["enum"]
      end

      def default
        fields["default"]
      end

      def description
        fields["description"]
      end
    end
  end
end
