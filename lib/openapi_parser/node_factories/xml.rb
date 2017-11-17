# frozen_string_literal: true

require "openapi_parser/nodes/xml"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Xml
      include NodeFactory::Object

      allow_extensions
      field "name", input_type: String
      field "namespace", input_type: String
      field "prefix", input_type: String
      field "attribute", input_type: :boolean, default: false
      field "wrapped", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Nodes::Xml.new(data, context)
      end
    end
  end
end
