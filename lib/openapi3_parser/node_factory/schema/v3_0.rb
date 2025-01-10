# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    module Schema
      class V3_0 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        include Schema::Common

        allow_extensions
        # OpenAPI 3.0 requires a type of String, whereas 3.1 up are String or Array
        field "type", input_type: String

        def build_node(data, node_context)
          Node::Schema::V3_0.new(data, node_context)
        end
      end
    end
  end
end
