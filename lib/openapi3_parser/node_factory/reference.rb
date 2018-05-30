# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/fields/reference"

module Openapi3Parser
  module NodeFactory
    class Reference < NodeFactory::Object
      field "$ref", input_type: String, required: true, factory: :ref_factory

      attr_reader :factory

      def initialize(context, factory)
        @factory = factory
        super(context)
      end

      private

      def build_node
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
