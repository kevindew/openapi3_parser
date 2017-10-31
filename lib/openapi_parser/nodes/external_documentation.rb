# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class ExternalDocumentation
      include Node

      allow_extensions

      field "description", input_type: String
      field "url", required: true, input_type: String

      def description
        fields["description"]
      end

      def url
        fields["url"]
      end
    end
  end
end
