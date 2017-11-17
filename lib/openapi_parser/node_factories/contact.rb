# frozen_string_literal: true

require "openapi_parser/nodes/contact"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Contact
      include NodeFactory::Object

      allow_extensions

      field "name", input_type: String
      field "url", input_type: String
      field "email", input_type: String

      private

      def build_object(data, context)
        Nodes::Contact.new(data, context)
      end
    end
  end
end
