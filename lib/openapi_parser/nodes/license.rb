# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class License
      include Node

      allow_extensions

      field "name", input_type: String, required: true
      field "url", input_type: String

      def name
        fields["name"]
      end

      def url
        fields["url"]
      end
    end
  end
end
