# frozen_string_literal: true

module Openapi3Parser
  module Node
    class Placeholder
      def self.resolve(potential_placeholder)
        if potential_placeholder.is_a?(Placeholder)
          potential_placeholder.node
        else
          potential_placeholder
        end
      end

      def initialize(node_factory, field, parent_context)
        @node_factory = node_factory
        @field = field
        @parent_context = parent_context
      end

      def node
        @node ||= begin
                    node_context = Context.next_field(parent_context,
                                                      field,
                                                      node_factory.context)
                    node_factory.node(node_context)
                  end
      end

      private

      attr_reader :node_factory, :field, :parent_context
    end
  end
end
