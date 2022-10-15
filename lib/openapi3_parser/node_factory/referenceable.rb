# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module Referenceable
      def in_recursive_loop?
        return false unless data.respond_to?(:[])

        data["$ref"]&.self_referencing?
      end

      def referenced_factory
        return unless data.respond_to?(:[])

        data["$ref"]&.referenced_factory
      end

      def resolves?(control_locations = nil)
        control_locations ||= [context.source_location]

        return true unless referenced_factory.respond_to?(:resolves?)
        # recursive loop of references that never references an object
        return false if control_locations.include?(referenced_factory.context.source_location)

        referenced_factory.resolves?(control_locations + [context.source_location])
      end

      def errors
        if in_recursive_loop?
          @errors ||= Validation::ErrorCollection.new
        else
          super
        end
      end

      def resolved_referenced_factories
        @resolved_referenced_factories ||= if resolves?
                                             collect_referenced_factories(self)
                                           else
                                             []
                                           end
      end

      private

      def collect_referenced_factories(factory, referenced_factories = [])
        return referenced_factories unless factory.respond_to?(:referenced_factory)

        if factory.referenced_factory
          referenced_factories << factory.referenced_factory
          collect_referenced_factories(factory.referenced_factory, referenced_factories)
        end

        referenced_factories
      end
    end
  end
end
