# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class PathItem < NodeFactory::Object
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

      private

      def build_object(data, context)
        ref = data.delete("$ref")
        return Node::PathItem.new(data, context) unless ref

        Node::PathItem.new(merge_data(ref.node_data, data), ref.node_context)
      end

      def ref_factory(context)
        NodeFactory::Fields::Reference.new(context, self.class)
      end

      def operation_factory(context)
        NodeFactory::Operation.new(context)
      end

      def servers_factory(context)
        NodeFactory::Array.new(
          context,
          value_factory: NodeFactory::Server
        )
      end

      def build_resolved_input
        ref = data["$ref"]
        data_without_ref = super.tap { |d| d.delete("$ref") }
        return data_without_ref unless ref

        merge_data(ref.resolved_input || {}, data_without_ref)
      end

      def merge_data(base, priority)
        base.merge(priority) do |_, old, new|
          new.nil? ? old : new
        end
      end

      def parameters_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Parameter)

        validate_parameters = lambda do |validatable|
          validatable.add_error(
            Validators::DuplicateParameters.call(
              validatable.factory.resolved_input
            )
          )
        end

        NodeFactory::Array.new(context,
                               value_factory: factory,
                               validate: validate_parameters)
      end
    end
  end
end
