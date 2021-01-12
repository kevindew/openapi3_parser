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

      # Group errors by those in the same location for the same node
      #
      # @return [Array<LocationTypeGroup]
      def group_errors
        grouped = group_by do |e|
          [e.source_location.to_s, e.for_type]
        end

        grouped.map do |_, errors|
          LocationTypeGroup.new(errors[0].source_location,
                                errors[0].for_type,
                                errors)
        end
      end

      # Return a hash structure where the location is key and the errors are
      # values
      #
      # @return [Hash]
      def to_h
        grouped = group_errors.group_by { |g| g.source_location.to_s }

        grouped.each_with_object({}) do |(_, items), memo|
          items.each do |item|
            key = item.location_summary(with_type: items.count > 1)
            memo[key] = memo.fetch(key, []) + item.errors.map(&:to_s)
          end
        end
      end

      # @return [String]
      def inspect
        "#{self.class.name}(errors: #{to_h})"
      end

      LocationTypeGroup = Struct.new(:source_location, :for_type, :errors) do
        def location_summary(with_type: false)
          string = source_location.to_s
          string << " (as #{for_type})" if with_type && !for_type&.empty?
          string
        end
      end
    end
  end
end
