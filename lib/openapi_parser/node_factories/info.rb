# frozen_string_literal: true

require "openapi_parser/nodes/info"
require "openapi_parser/node_factories/license"
require "openapi_parser/node_factories/contact"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Info
      include NodeFactory::Object

      allow_extensions
      field "title", input_type: String, required: true
      field "description", input_type: String
      field "termsOfService", input_type: String
      field "contact", factory: Contact
      field "license", factory: License
      field "version", input_type: String, required: true

      private

      def build_object(data, context)
        Nodes::Info.new(data, context)
      end
    end
  end
end
