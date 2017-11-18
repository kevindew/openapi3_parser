# frozen_string_literal: true

require "openapi_parser/node/object"

module OpenapiParser
  module Nodes
    class Contact
      include Node::Object

      def name
        data["name"]
      end

      def url
        data["url"]
      end

      def email
        data["email"]
      end
    end
  end
end
