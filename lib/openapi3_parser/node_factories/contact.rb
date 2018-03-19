# frozen_string_literal: true

require "openapi3_parser/node/contact"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/validators/url"
require "openapi3_parser/validators/email"

module Openapi3Parser
  module NodeFactories
    class Contact
      include NodeFactory::Object

      allow_extensions

      field "name", input_type: String
      field "url",
            input_type: String,
            validate: ->(input) { Validators::Url.call(input) }
      field "email",
            input_type: String,
            validate: ->(input) { Validators::Email.call(input) }

      private

      def build_object(data, context)
        Node::Contact.new(data, context)
      end
    end
  end
end
