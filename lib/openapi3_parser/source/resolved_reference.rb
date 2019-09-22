# frozen_string_literal: true

module Openapi3Parser
  class Source
    class ResolvedReference
      extend Forwardable

      def_delegators :factory, :resolved_input, :node

      attr_reader :reference, :factory

      def initialize(reference, factory)
        @reference = reference
        @factory = factory
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= Array(build_errors)
      end

      private

      def build_errors
        source = factory.context.source
        return source_unavailabe_error unless source.available?

        unless source.has_pointer?(reference.json_pointer)
          return pointer_missing_error
        end

        resolution_error unless factory.valid?
      end

      def source_unavailabe_error
        # @todo include a location
        "Source is unavailable"
      end

      def pointer_missing_error
        # @todo include a location and a pointer
        "Source does not have pointer"
      end

      def resolution_error
        # @todo include exepected object
        "Reference does not resolve to a valid object"
      end
    end
  end
end
