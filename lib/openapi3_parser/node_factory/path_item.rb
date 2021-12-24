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

      def build_object(data, node_context)
        ref = data.delete("$ref")
        context = if node_context.input.keys == %w[$ref]
                    referenced_factory = ref.node_factory.referenced_factory
                    Node::Context.resolved_reference(
                      node_context,
                      referenced_factory.context
                    )
                  else
                    node_context
                  end

        reference_data = ref.nil_input? ? {} : ref.node.node_data

        data = merge_data(reference_data, data).tap do |d|
          d["servers"] = root_server_data(context) if d["servers"].node.empty?
        end

        Node::PathItem.new(data, context)
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
          if new.nil? || (new.respond_to?(:nil_input?) && new.nil_input?)
            old
          else
            new
          end
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

      def root_server_data(node_context)
        root_servers = node_context.document.root.node_data["servers"]
        Node::Placeholder.new(root_servers.node_factory,
                              "servers",
                              node_context)
      end
    end
  end
end
