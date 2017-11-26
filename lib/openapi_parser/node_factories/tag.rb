# frozen_string_literal: true

require "openapi_parser/nodes/tag"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factories/external_documentation"

module OpenapiParser
  module NodeFactories
    class Tag
      include NodeFactory::Object

      allow_extensions
      field "name", input_type: String, required: true
      field "description", input_type: String
      field "externalDocs", factory: NodeFactories::ExternalDocumentation

      private

      def build_object(data, context)
        Nodes::Tag.new(data, context)
      end
    end
  end
end
