# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/input_validator"
require "openapi3_parser/validators/absolute_uri"

module Openapi3Parser
  module NodeFactory
    class Xml < NodeFactory::Object
      allow_extensions
      field "name", input_type: String
      field "namespace",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::AbsoluteUri)
      field "prefix", input_type: String
      field "attribute", input_type: :boolean, default: false
      field "wrapped", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Node::Xml.new(data, context)
      end
    end
  end
end
