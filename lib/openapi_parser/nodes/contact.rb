# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Contact
      include Node::Object

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
