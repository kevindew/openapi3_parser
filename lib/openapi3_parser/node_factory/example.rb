# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/input_validator"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactory
    class Example < NodeFactory::Object
      allow_extensions

      field "summary", input_type: String
      field "description", input_type: String
      field "value"
      field "externalValue",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::Url)

      mutually_exclusive "value", "externalValue"

      def build_node(data, node_context)
        Node::Example.new(data, node_context)
      end
    end
  end
end
