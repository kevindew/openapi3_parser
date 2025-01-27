# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    module Schema
      class V3_0 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        include Schema::Common

        allow_extensions
        # OpenAPI 3.0 requires a type of String, whereas >= 3.1 is String or Array
        field "type", input_type: String

        # JSON Schema 2016 has these exclusive fields as booleans whereas
        # in JSON Schema 2021 (OpenAPI 3.1) these are numbers
        field "exclusiveMaximum", input_type: :boolean, default: false
        field "exclusiveMinimum", input_type: :boolean, default: false

        validate :items_for_array

        def build_node(data, node_context)
          Node::Schema::V3_0.new(data, node_context)
        end

        private

        # Only the OpenAPI 3.0 spec references the requirement for this
        # validation [1]. There doesn't seem to be equivalent in JSON Schema
        # 2020-12
        #
        # [1]: https://spec.openapis.org/oas/v3.0.4.html#json-schema-keywords)
        def items_for_array(validatable)
          return unless validatable.input["type"] == "array"
          return unless validatable.factory.resolved_input["items"].nil?

          validatable.add_error("items must be defined for a type of array")
        end
      end
    end
  end
end
