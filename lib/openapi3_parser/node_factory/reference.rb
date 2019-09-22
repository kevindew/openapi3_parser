# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Reference < NodeFactory::Object
      field "$ref", input_type: String, required: true, factory: :ref_factory

      attr_reader :factory

      def initialize(context, factory)
        @factory = factory
        super(context)
      end

      def in_recursive_loop?
        data["$ref"].context.self_referencing?
      end

      private

      def build_node(node_context)
        # @todo this should raise an error if the reference is invalid
        data["$ref"].node(node_context)
      end

      def ref_factory(context)
        if context.self_referencing?
          NodeFactory::Fields::RecursiveReference.new(context, factory)
        else
          NodeFactory::Fields::Reference.new(context, factory)
        end
      end

      def build_resolved_input
        data["$ref"].resolved_input
      end
    end
  end
end
