# frozen_string_literal: true

module Openapi3Parser
  module Validation
    class Validatable
      attr_reader :context, :errors, :factory

      UNDEFINED = Class.new

      def initialize(factory, context: nil)
        @factory = factory
        @context = context || factory.context
        @errors = []
      end

      def input
        context.input
      end

      def add_error(error, given_context = nil, factory_class = UNDEFINED)
        return unless error
        return @errors << error if error.is_a?(Validation::Error)

        @errors << Validation::Error.new(
          error,
          given_context || context,
          factory_class == UNDEFINED ? factory.class : factory_class
        )
      end

      def add_errors(errors)
        errors = errors.to_a if errors.respond_to?(:to_a)
        errors.each { |e| add_error(e) }
      end

      def collection
        ErrorCollection.new(errors)
      end
    end
  end
end
