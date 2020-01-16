# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/parameter_like"

module Openapi3Parser
  module NodeFactory
    class Parameter < NodeFactory::Object
      include ParameterLike

      allow_extensions

      field "name", input_type: String, required: true
      field "in", input_type: String,
                  required: true,
                  validate: :validate_in
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

      field "content", factory: :content_factory

      mutually_exclusive "example", "examples"

      validate do |validatable|
        if validatable.input["in"] == "path" && !validatable.input["required"]
          validatable.add_error(
            "Must be included and true for a path parameter",
            Context.next_field(validatable.context, "required")
          )
        end
      end

      private

      def build_object(data, context)
        Node::Parameter.new(data, context)
      end

      def default_style
        return "simple" if %w[path header].include?(context.input["in"])

        "form"
      end

      def validate_in(validatable)
        return if %w[header query cookie path].include?(validatable.input)

        validatable.add_error("in can only be header, query, cookie, or path")
      end
    end
  end
end
