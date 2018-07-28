# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    class RecursivePointer
      attr_reader :reference_context

      def initialize(reference_context)
        @reference_context = reference_context
      end

      def node
        reference_context.node
      end
    end
  end
end
