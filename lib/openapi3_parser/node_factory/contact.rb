# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/input_validator"
require "openapi3_parser/validators/email"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactory
    class Contact < NodeFactory::Object
      allow_extensions

      field "name", input_type: String
      field "url",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::Url)
      field "email",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::Email)

      def build_node(data, node_context)
        Node::Contact.new(data, node_context)
      end
    end
  end
end
