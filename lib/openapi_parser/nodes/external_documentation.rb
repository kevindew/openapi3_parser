# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class ExternalDocumentation
      include Node::Object

      def description
        fields["description"]
      end

      def url
        fields["url"]
      end
    end
  end
end
