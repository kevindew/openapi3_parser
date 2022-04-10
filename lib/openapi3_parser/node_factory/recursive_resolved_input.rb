# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    # Used in the place of a hash for resolved input so the value can
    # be looked up at runtime avoiding a recursive loop.
    class RecursiveResolvedInput
      extend Forwardable
      include Enumerable

      def_delegators :value, :each, :[], :keys
      attr_reader :factory

      def initialize(factory)
        @factory = factory
      end

      def value
        @factory.resolved_input
      end
    end
  end
end
