# frozen_string_literal: true

require "openapi_parser/nodes/license"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class License
      include NodeFactory::Object

      allow_extensions
      field "name", input_type: String, required: true
      field "url", input_type: String

      private

      def build_object(data, context)
        Nodes::License.new(data, context)
      end
    end
  end
end
