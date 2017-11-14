# frozen_string_literal: true

module OpenapiParser
  module Validation
    class ErrorCollection
      def initialize(*errors)
        reset
        append(*errors)
      end

      def append(*errors)
        errors.each { |e| @errors << e }
      end

      def reset
        @errors = []
      end

      def merge(error_collection)
        append(*error_collection.to_a)
      end

      def empty?
        errors.empty?
      end

      def to_a
        errors.dup
      end

      private

      attr_reader :errors
    end
  end
end
