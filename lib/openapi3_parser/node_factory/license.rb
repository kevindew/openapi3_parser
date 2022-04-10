# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/input_validator"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactory
    class License < NodeFactory::Object
      allow_extensions
      field "name", input_type: String, required: true
      field "url",
            input_type: String,
            validate: Validation::InputValidator.new(Validators::Url)

      def build_node(data, node_context)
        Node::License.new(data, node_context)
      end
    end
  end
end
