# frozen_string_literal: true

require "openapi3_parser/node/path_item"
require "openapi3_parser/node_factory/fields/reference"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/object/node_builder"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factories/array"
require "openapi3_parser/node_factories/server"
require "openapi3_parser/node_factories/operation"
require "openapi3_parser/node_factories/parameter"

module Openapi3Parser
  module NodeFactories
    class PathItem
      include NodeFactory::Object

      allow_extensions
      field "$ref", input_type: String, factory: :ref_factory
      field "summary", input_type: String
      field "description", input_type: String
      field "get", factory: :operation_factory
      field "put", factory: :operation_factory
      field "post", factory: :operation_factory
      field "delete", factory: :operation_factory
      field "options", factory: :operation_factory
      field "head", factory: :operation_factory
      field "patch", factory: :operation_factory
      field "trace", factory: :operation_factory
      field "servers", factory: :servers_factory
      field "parameters", factory: :parameters_factory

      def node_data
        NodeBuilder.new(processed_input, self).data
      end

      private

      def build_object(data, context)
        ref = data.delete("$ref")
        return Node::PathItem.new(data, context) unless ref

        merged_data = ref.node_data.merge(data) do |_, new, old|
          new.nil? ? old : new
        end
        Node::PathItem.new(merged_data, ref.node_context)
      end

      def ref_factory(context)
        Fields::Reference.new(context, self.class)
      end

      def operation_factory(context)
        NodeFactories::Operation.new(context)
      end

      def servers_factory(context)
        NodeFactories::Array.new(
          context,
          value_factory: NodeFactories::Server
        )
      end

      def parameters_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Parameter)
        NodeFactories::Array.new(context, value_factory: factory)
      end
    end
  end
end
