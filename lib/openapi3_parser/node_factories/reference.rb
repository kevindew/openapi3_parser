# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/fields/reference"

module Openapi3Parser
  module NodeFactories
    class Reference
      include NodeFactory::Object

      field "$ref", input_type: String, required: true, factory: :ref_factory

      attr_reader :factory

      def initialize(context, factory)
        @factory = factory
        super(context)
      end

      private

      def build_node(input)
        input["$ref"].node
      end

      def ref_factory(context)
        Fields::Reference.new(context, factory)
      end

      def build_resolved_input
        processed_input["$ref"].data
      end
    end
  end
end
