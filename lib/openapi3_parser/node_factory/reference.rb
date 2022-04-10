# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/referenceable"

module Openapi3Parser
  module NodeFactory
    class Reference < NodeFactory::Object
      include Referenceable

      field "$ref", input_type: String, required: true, factory: :ref_factory

      attr_reader :factory

      def initialize(context, factory)
        @factory = factory
        super(context)
      end

      private

      def ref_factory(context)
        NodeFactory::Fields::Reference.new(context, factory)
      end
    end
  end
end
