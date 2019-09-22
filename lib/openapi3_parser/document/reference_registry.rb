# frozen_string_literal: true

module Openapi3Parser
  class Document
    class ReferenceRegistry
      attr_reader :sources, :factories

      def initialize
        @sources = []
        @factories = []
      end

      def freeze
        sources.freeze
        factories.freeze
        super
      end

      def resolve(unbuilt_factory, source_location, reference_location)
        source = source_location.source
        sources << source unless sources.include?(source)

        existing_factory = factories.find do |f|
          # @todo some type matching
          f.context.source_location == source_location
        end

        return existing_factory if existing_factory

        factory = build_factory(unbuilt_factory,
                                source_location,
                                reference_location)

        factories << factory

        factory
      end

      private

      def build_factory(unbuilt_factory, source_location, reference_location)
        next_context = NodeFactory::Context.resolved_reference(
          source_location: source_location,
          reference_location: reference_location
        )

        if unbuilt_factory.is_a?(Class)
          unbuilt_factory.new(next_context)
        else
          unbuilt_factory.call(next_context)
        end
      end
    end
  end
end
