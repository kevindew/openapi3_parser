# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class OptionalReference
      def initialize(factory)
        @factory = factory
      end

      def object_type
        "#{self.class}[#{factory.object_type}]}"
      end

      def call(context)
        reference = context.input.is_a?(Hash) && context.input["$ref"]

        if reference
          NodeFactory::Reference.new(context, self)
        else
          factory.new(context)
        end
      end

      private

      attr_reader :factory
    end
  end
end
