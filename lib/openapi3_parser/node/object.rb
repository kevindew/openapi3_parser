# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  module Node
    class Object
      extend Forwardable
      include Enumerable

      def_delegators :node_data, :keys, :empty?
      attr_reader :node_data, :node_context

      def initialize(data, context)
        @node_data = data
        @node_context = context
      end

      # Look up an attribute of the node by the name it has in the OpenAPI
      # document.
      #
      # @example Look up by OpenAPI naming
      #   obj["externalDocs"]
      #
      # @example Look up by symbol
      #   obj[:servers]
      #
      # @example Look up an extension
      #   obj["x-myExtension"]
      #
      # @param [String, Symbol] value
      #
      # @return anything
      def [](value)
        Placeholder.resolve(node_data[value.to_s])
      end

      # Look up an extension provided for this object, doesn't need a prefix of
      # "x-"
      #
      # @example Looking up an extension provided as "x-extra"
      #   obj.extension("extra")
      #
      # @param [String, Symbol] value
      #
      # @return [Hash, Array, Numeric, String, true, false, nil]
      def extension(value)
        self["x-#{value}"]
      end

      # @param [Any]  other
      #
      # @return [Boolean]
      def ==(other)
        other.instance_of?(self.class) &&
          node_context.same_data_and_source?(other.node_context)
      end

      # Iterates through the data of this node, used by Enumerable
      #
      # @return [Object]
      def each(&block)
        Placeholder.each(node_data, &block)
      end

      # Provide an array of values for this object, a partner to the #keys
      # method
      #
      # @return [Array]
      def values
        map(&:last)
      end

      # Used to render fields that can be in markdown syntax into HTML
      # @param  [String, nil] value
      # @return [String, nil]
      def render_markdown(value)
        return if value.nil?

        Markdown.to_html(value)
      end

      # Used to access a node relative to this node
      #
      # @example Looking up the parent node of this node
      #   obj.node_at("#..")
      #
      # @example Jumping way down the tree
      #   obj.node_at("#properties/Field/type")
      #
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
