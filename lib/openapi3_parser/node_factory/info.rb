# frozen_string_literal: true

require "openapi3_parser/node_factory/contact"
require "openapi3_parser/node_factory/license"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/input_validator"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactory
    class Info < NodeFactory::Object
      allow_extensions
      field "title", input_type: String, required: true
      field "description", input_type: String
      field "termsOfService",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::Url)
      field "contact", factory: NodeFactory::Contact
      field "license", factory: NodeFactory::License
      field "version", input_type: String, required: true

      private

      def build_object(data, context)
        Node::Info.new(data, context)
      end
    end
  end
end
