# frozen_string_literal: true

require "openapi_parser/nodes/parameter"
require "openapi_parser/node_factories/parameter/parameter_like"
require "openapi_parser/node_factory/object"

module OpenapiParser
  module NodeFactories
    class Parameter
      include NodeFactory::Object
      include Parameter::ParameterLike

      allow_extensions

      field "name", input_type: String, required: true
      field "in", input_type: String, required: true
      field "description", input_type: String
      field "required", input_type: :boolean, default: false
      field "deprecated", input_type: :boolean, default: false
      field "allowEmptyValue", input_type: :boolean, default: false

      field "style", input_type: String, default: :default_style
      field "explode", input_type: :boolean, default: :default_explode
      field "allowReserved", input_type: :boolean, default: false
      field "schema", factory: :schema_factory
      field "example"
      field "examples", factory: :examples_factory

      # field "content", factory: :content_factory

      private

      def build_object(data, context)
        Nodes::Parameter.new(data, context)
      end

      def default_style
        return "simple" if %w[path header].include?(context.input["in"])
        "form"
      end
    end
  end
end
