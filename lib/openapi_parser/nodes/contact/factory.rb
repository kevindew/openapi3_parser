# frozen_string_literal: true

require "openapi_parser/nodes/contact"
require "openapi_parser/node/factory/object"

module OpenapiParser
  module Nodes
    class Contact
      class Factory
        include Node::Factory::Object

        allow_extensions

        field "name", input_type: String
        field "url", input_type: String
        field "email", input_type: String

        private

        def build_object(data, context)
          Contact.new(data, context)
        end
      end
    end
  end
end
