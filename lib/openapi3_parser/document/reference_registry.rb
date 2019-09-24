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

      def register(unbuilt_factory, source_location, reference_factory_context)
        register_source(source_location.source)
        object_type = unbuilt_factory.object_type
        existing_factory = factory(object_type, source_location)

        return existing_factory if existing_factory

        build_factory(
          unbuilt_factory,
          source_location,
          reference_factory_context
        ).tap { |f| register_factory(object_type, f) }
      end

      def factory(object_type, source_location)
        factories_by_type[object_type]&.find do |f|
          f.context.source_location == source_location
        end
      end

      private

      attr_reader :factories_by_type

      def register_source(source)
        sources << source unless sources.include?(source)
      end

      def register_factory(object_type, factory)
        factories_by_type[object_type] ||= []
        factories_by_type[object_type] << factory
      end

      def build_factory(unbuilt_factory,
                        source_location,
                        reference_factory_context)
        next_context = NodeFactory::Context.resolved_reference(
          reference_factory_context,
          source_location: source_location
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
