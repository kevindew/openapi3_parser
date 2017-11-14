# frozen_string_literal: true

require "openapi_parser/nodes/license"
require "openapi_parser/node/factory/object"

module OpenapiParser
  module Nodes
    class License
      class Factory
        include Node::Factory::Object

        allow_extensions
        field "name", input_type: String, required: true
        field "url", input_type: String

        private

        def build_object(data, context)
          License.new(data, context)
        end
      end
    end
  end
end
