# frozen_string_literal: true

require "openapi_parser/nodes/info"
require "openapi_parser/nodes/license/factory"
require "openapi_parser/node/factory/object"

module OpenapiParser
  module Nodes
    class Info
      class Factory
        include Node::Factory::Object

        allow_extensions
        field "title", input_type: String, required: true
        field "description", input_type: String
        field "termsOfService", input_type: String
        field "contact", factory: Contact::Factory
        field "license", factory: License::Factory
        field "version", input_type: String, required: true

        private

        def build_object(data, context)
          Info.new(data, context)
        end
      end
    end
  end
end
