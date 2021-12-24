# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  class Source
    class ResolvedReference
      extend Forwardable

      def_delegators :source_location, :source
      def_delegators :factory, :resolved_input, :node

      attr_reader :source_location, :object_type

      def initialize(source_location:,
                     object_type:,
                     reference_registry:)
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
        @factory ||= reference_registry.factory(object_type, source_location).tap do |factory|
          message = "Unregistered node factory at #{source_location}"
          raise Openapi3Parser::Error, message unless factory
        end
      end

      private

      attr_reader :reference_registry

      def build_errors
        return source_unavailabe_error unless source.available?
        return pointer_missing_error unless source_location.pointer_defined?

        resolution_error unless factory.valid?
      end

      def source_unavailabe_error
        "Failed to open source #{source.relative_to_root}"
      end

      def pointer_missing_error
        suffix = source.root? ? "" : " in source #{source.relative_to_root}"
        "#{source_location.pointer} is not defined#{suffix}"
      end

      def resolution_error
        "#{source_location} does not resolve to a valid object"
      end
    end
  end
end
