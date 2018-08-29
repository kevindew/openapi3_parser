# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/parameter_like"

module Openapi3Parser
  module NodeFactory
    class Header < NodeFactory::Object
      include ParameterLike

      allow_extensions

      field "description", input_type: String
      field "required", input_type: :boolean, default: false
      field "deprecated", input_type: :boolean, default: false
      field "allowEmptyValue", input_type: :boolean, default: false

      field "style", input_type: String, default: "simple"
      field "explode", input_type: :boolean, default: :default_explode
      field "allowReserved", input_type: :boolean, default: false
      field "schema", factory: :schema_factory
      field "example"
      field "examples", factory: :examples_factory

      field "content", factory: :content_factory

      private

      def build_object(data, context)
        Node::Header.new(data, context)
      end
    end
  end
end
