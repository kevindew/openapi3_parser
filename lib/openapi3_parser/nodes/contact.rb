# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
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
