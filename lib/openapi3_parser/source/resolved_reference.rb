# frozen_string_literal: true

module Openapi3Parser
  class Source
    class ResolvedReference
      extend Forwardable

      def_delegators :source_location, :source
      def_delegators :factory, :resolved_input, :node

      attr_reader :reference, :source_location, :object_type

      def initialize(reference:,
                     source_location:,
                     object_type:,
                     reference_registry:)
        @reference = reference
        @source_location = source_location
        @object_type = object_type
        @reference_registry = reference_registry
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= Array(build_errors)
      end

      def factory
        @factory ||= begin
          reference_registry
            .factory(object_type, source_location)
            .tap do |factory|
              message = "Unregistered node factory at #{source_location}"
              raise Openapi3Parser::Error, message unless factory
            end
        end
      end

      private

      attr_reader :reference_registry

      def build_errors
        return source_unavailabe_error unless source.available?

        unless source.has_pointer?(reference.json_pointer)
          return pointer_missing_error
        end

        resolution_error unless factory.valid?
      end

      def source_unavailabe_error
        "Failed to open source #{source.relative_to_root}"
      end

      def pointer_missing_error
        suffix = source.root? ? "" : " in source #{source.relative_to_root}"
        "#{reference} is not defined#{suffix}"
      end

      def resolution_error
        "#{source_location} does not resolve to a valid object"
      end
    end
  end
end
