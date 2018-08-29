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
        data["$ref"].in_recursive_loop?
      end

      def recursive_pointer
        NodeFactory::RecursivePointer.new(data["$ref"].reference_context)
      end

      private

      def build_node
        if in_recursive_loop?
          raise Error::InRecursiveStructure,
                "Can't build node as it references itself, use "\
                "recursive_pointer"
        end
        data["$ref"].node
      end

      def ref_factory(context)
        NodeFactory::Fields::Reference.new(context, factory)
      end

      def build_resolved_input
        data["$ref"].resolved_input
      end
    end
  end
end
