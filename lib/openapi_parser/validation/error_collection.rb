# frozen_string_literal: true

module OpenapiParser
  module Validation
    class ErrorCollection
      attr_reader :errors

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

      def errors
        @errors.dup
      end

      def merge(error_collection)
        append(*error_collection.errors)
      end

      def empty?
        @errors.empty?
      end
    end
  end
end
