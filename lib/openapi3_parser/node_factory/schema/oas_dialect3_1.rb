# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/referenceable"

module Openapi3Parser
  module NodeFactory
    module Schema
      class OasDialect3_1 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        include Referenceable
        # Allows any extension as per:
        # https://github.com/OAI/OpenAPI-Specification/blob/a1facce1b3621df3630cb692e9fbe18a7612ea6d/versions/3.1.0.md#fixed-fields-20
        allow_extensions(regex: /.*/)

        field "$ref", input_type: String, factory: :ref_factory
        field "properties", factory: :properties_factory

        def build_node(data, node_context)
          Node::Schema::OasDialect3_1.new(data, node_context)
        end

        private

        def ref_factory(context)
          NodeFactory::Fields::Reference.new(context, self.class)
        end

        def properties_factory(context)
          NodeFactory::Map.new(
            context,
            value_factory: NodeFactory::Schema.factory(context)
          )
        end
      end
    end
  end
end
