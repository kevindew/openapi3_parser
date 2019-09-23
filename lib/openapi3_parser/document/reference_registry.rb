# frozen_string_literal: true

module Openapi3Parser
  class Document
    class ReferenceRegistry
      attr_reader :sources

      def initialize
        @sources = []
        @factories_by_type = {}
      end

      def freeze
        sources.freeze
        factories_by_type.freeze.each(&:freeze)
        super
      end

      def factories
        factories_by_type.values.flatten
      end

      def resolve(unbuilt_factory, source_location, reference_location)
        source = source_location.source
        sources << source unless sources.include?(source)
        object_type = unbuilt_factory.object_type

        existing_factory = factories_by_type[object_type]&.find do |f|
          f.context.source_location == source_location
        end

        return existing_factory if existing_factory

        factory = build_factory(unbuilt_factory,
                                source_location,
                                reference_location)

        factories_by_type[object_type] ||= []
        factories_by_type[object_type] << factory

        factory
      end

      private

      attr_reader :factories_by_type

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
