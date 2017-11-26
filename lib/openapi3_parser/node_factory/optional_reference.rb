# frozen_string_literal: true

require "openapi3_parser/node_factories/reference"

module Openapi3Parser
  module NodeFactory
    class OptionalReference
      def initialize(factory)
        @factory = factory
      end

      def call(context)
        reference = context.input.is_a?(Hash) && context.input["$ref"]
        return NodeFactories::Reference.new(context, self) if reference
        factory.new(context)
      end

      private

      attr_reader :factory
    end
  end
end
