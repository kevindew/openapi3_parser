# frozen_string_literal: true

require "openapi3_parser/node/example"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactories
    class Example
      include NodeFactory::Object

      allow_extensions

      field "summary", input_type: String
      field "description", input_type: String
      field "value"
      field "externalValue",
            input_type: String,
            validate: ->(input) { Validators::Url.call(input) }

      mutually_exclusive "value", "externalValue"

      private

      def build_object(data, context)
        Node::Example.new(data, context)
      end
    end
  end
end
