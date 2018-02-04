# frozen_string_literal: true

require "openapi3_parser/node/license"
require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactories
    class License
      include NodeFactory::Object

      allow_extensions
      field "name", input_type: String, required: true
      field "url", input_type: String

      private

      def build_object(data, context)
        Node::License.new(data, context)
      end
    end
  end
end
