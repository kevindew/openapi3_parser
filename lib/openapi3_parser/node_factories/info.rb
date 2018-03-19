# frozen_string_literal: true

require "openapi3_parser/node/info"
require "openapi3_parser/node_factories/license"
require "openapi3_parser/node_factories/contact"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/validators/url"

module Openapi3Parser
  module NodeFactories
    class Info
      include NodeFactory::Object

      allow_extensions
      field "title", input_type: String, required: true
      field "description", input_type: String
      field "termsOfService",
            input_type: String,
            validate: ->(input) { Validators::Url.call(input) }
      field "contact", factory: Contact
      field "license", factory: License
      field "version", input_type: String, required: true

      private

      def build_object(data, context)
        Node::Info.new(data, context)
      end
    end
  end
end
