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
        data["$ref"].self_referencing?
      end

      def referenced_factory
        data["$ref"].referenced_factory
      end

      def resolves?(control_factory = nil)
        control_factory ||= self

        return true unless referenced_factory.is_a?(Reference)
        # recursive loop of references that never references an object
        return false if referenced_factory == control_factory

        referenced_factory.resolves?(control_factory)
      end

      def errors
        if in_recursive_loop?
          @errors ||= Validation::ErrorCollection.new
        else
          super
        end
      end

      private

      def build_node(node_context)
        TypeChecker.raise_on_invalid_type(context, type: ::Hash)
        ObjectFactory::Validator.call(self, raise_on_invalid: true)
        data["$ref"].node(node_context)
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
