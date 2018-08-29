# frozen_string_literal: true

module Openapi3Parser
  class Document
    class ReferenceRegister
      attr_reader :sources, :factories

      def initialize
        @sources = []
        @factories = []
      end

      def register(factory)
        error = "Can't register references when the register is frozen"
        raise Error::ImmutableObject, error if frozen?
        context = factory.context
        add_source(context.source_location.source)
        add_factory(factory)
      end

      def freeze
        sources.freeze
        factories.freeze
        super
      end

      private

      def add_source(source)
        return if sources.include?(source)
        sources << source
      end

      def add_factory(factory)
        return if factory_registered?(factory)
        factories << factory
      end

      def factory_registered?(factory)
        source_location = factory.context.source_location
        factories.any? do |f|
          same_location = f.context.source_location == source_location
          same_location && f.class == factory.class
        end
      end
    end
  end
end
