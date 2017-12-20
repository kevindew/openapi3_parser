# frozen_string_literal: true

require "openapi3_parser/source"

module Openapi3Parser
  class Source
    class ReferenceResolver
      def initialize(reference, factory, context)
        @reference = reference
        @factory = factory
        @context = context
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= Array(build_errors)
      end

      def node
        reference_factory.node
      end

      def in_root_source?
        # @TODO
        true
      end

      private

      attr_reader :reference, :factory, :context

      def source
        @source ||= context.source.resolve_source(reference)
      end

      def build_errors
        return source_unavailabe_error unless source.available?
        return pointer_missing_error unless source.has_pointer?(json_pointer)
        resolution_error unless reference_factory.valid?
      end

      def source_unavailabe_error
        # @TODO include a location
        "Source is unavailable"
      end

      def pointer_missing_error
        # @TODO include a location and a pointer
        "Source does not have pointer"
      end

      def resolution_error
        # @TODO include exepected object
        "Reference does not resolve to a valid object"
      end

      def json_pointer
        reference.json_pointer
      end

      def reference_factory
        @reference_factory ||= begin
                                 next_context = context.reference_namespace(
                                   source.data_at_pointer(json_pointer),
                                   context.namespace
                                 )
                                 build_factory(next_context)
                               end
      end

      def build_factory(context)
        factory.is_a?(Class) ? factory.new(context) : factory.call(context)
      end
    end
  end
end
