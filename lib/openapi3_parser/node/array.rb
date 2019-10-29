# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  module Node
    # An array within a OpenAPI document.
    # Very similar to a normal Ruby array, however this is read only and knows
    # the context of where it sits in an OpenAPI document
    #
    # The contents of the data will be dependent on where this document is in
    # the document hierachy.
    class Array
      extend Forwardable
      include Enumerable

      def_delegators :node_data, :empty?, :length, :size
      attr_reader :node_data, :node_context

      # @param [::Array] data     data used to populate this node
      # @param [Context] context  The context of this node in the document
      def initialize(data, context)
        @node_data = data
        @node_context = context
      end

      def [](index)
        Placeholder.resolve(node_data[index])
      end

      # Iterates through the data of this node, used by Enumerable
      #
      # @return [Object]
      def each(&block)
        Placeholder.each(node_data, &block)
      end

      # @param [Any]  other
      #
      # @return [Boolean]
      def ==(other)
        other.instance_of?(self.class) &&
          node_context.same_data_and_source?(other.node_context)
      end

      # Used to access a node relative to this node
      # @param  [Source::Pointer, ::Array, ::String] pointer_like
      # @return anything
      def node_at(pointer_like)
        current_pointer = node_context.document_location.pointer
        node_context.document.node_at(pointer_like, current_pointer)
      end

      # @return [String]
      def inspect
        fragment = node_context.document_location.pointer.fragment
        %{#{self.class.name}(#{fragment})}
      end
    end
  end
end
