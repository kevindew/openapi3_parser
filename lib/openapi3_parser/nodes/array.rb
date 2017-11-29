# frozen_string_literal: true

require "openapi3_parser/node/map"

module Openapi3Parser
  module Nodes
    # An array within a OpenAPI document.
    # Very similar to a normal Ruby array, however this is read only and knows
    # the context of where it sits in an OpenAPI document
    #
    # The contents of the data will be dependent on where this document is in
    # the document hierachy.
    class Array
      include Enumerable

      attr_reader :node_data, :node_context

      # @param [::Array] data     data used to populate this node
      # @param [Context] context  The context of this node in the document
      def initialize(data, context)
        @node_data = data
        @node_context = context
      end

      def [](value)
        node_data[value]
      end

      def each(&block)
        node_data.each(&block)
      end
    end
  end
end
