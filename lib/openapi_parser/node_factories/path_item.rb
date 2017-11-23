# frozen_string_literal: true

require "openapi_parser/nodes/path_item"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/object/node_builder"
require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/array"
require "openapi_parser/node_factories/server"
require "openapi_parser/node_factories/parameter"

module OpenapiParser
  module NodeFactories
    class PathItem
      include NodeFactory::Object

      allow_extensions
      field "$ref", input_type: String
      field "summary", input_type: String
      field "description", input_type: String
      field "servers", factory: :servers_factory
      field "parameters", factory: :parameters_factory

      def node_data
        NodeBuilder.new(processed_input, self).data
      end

      private

      def build_object(data, context)
        merged_data = merge_reference(data, context)
        merged_data.delete("$ref")
        Nodes::PathItem.new(merged_data, context)
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

      def merge_reference(data, context)
        return data unless data["$ref"]
        factory = context.resolve_reference do |ref_context|
          self.class.new(ref_context)
        end

        # @TODO In this situation we're basically sacrificing the reference
        # context as we don't know how to merge them. Should develop a system
        # to have a dual context
        factory.node_data.merge(data) do |_, new, old|
          new.nil? ? old : new
        end
      end
    end
  end
end
