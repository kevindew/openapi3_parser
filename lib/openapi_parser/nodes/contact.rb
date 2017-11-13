# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class Contact
      include Node

      allow_extensions

      field "name", input_type: String
      field "url", input_type: String
      field "email", input_type: String

      def name
        fields["name"]
      end

      def url
        fields["url"]
      end

      def email
        fields["email"]
      end
    end
  end
end
