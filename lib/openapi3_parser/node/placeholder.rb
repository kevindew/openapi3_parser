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

      # Used to iterate through hashes or arrays that may contain
      # Placeholder objects where these are resolved to being nodes
      # befor iteration
      def self.each(node_data, &block)
        resolved =
          if node_data.respond_to?(:keys)
            node_data.each_with_object({}) do |(key, value), memo|
              memo[key] = resolve(value)
            end
          else
            node_data.map { |item| resolve(item) }
          end

        resolved.each(&block)
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
