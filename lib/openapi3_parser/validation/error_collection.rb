# frozen_string_literal: true

module Openapi3Parser
  module Validation
    # An immutable collection of Validation::Error objects
    # @attr_reader [Array<Validation::Error>] errors
    class ErrorCollection
      include Enumerable

      # Combines ErrorCollection objects or arrays of Validation::Error objects
      # @param  [ErrorCollection, Array<Validation::Error>] errors
      # @param  [ErrorCollection, Array<Validation::Error>] other_errors
      # @return [ErrorCollection]
      def self.combine(errors, other_errors)
        new(errors.to_a + other_errors.to_a)
      end

      attr_reader :errors
      alias to_a errors

      # @param  [Array<Validation::Error>] errors
      def initialize(errors = [])
        @errors = errors.freeze
      end

      def empty?
        errors.empty?
      end

      def each(&block)
        errors.each(&block)
      end
    end
  end
end
