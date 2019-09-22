# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    # This class is used to specify the data and source information for a
    # NodeFactory.
    class Context
      # Create a context for the root of a document
      #
      # @param  [Object]  input
      # @param  [Source]  field
      # @return [Context]
      def self.root(input, source)
        new(input, source_location: Source::Location.new(source, []))
      end

      # Create a context for a field within the current contexts data
      # eg for a context of:
      #   root = Context.root({ "test" => {} }, source)
      # we can get the context of "test" with:
      #   test = Context.next_field(root, "test")
      #
      # @param  [Context] parent_context
      # @param  [String]  field
      # @return [Context]
      def self.next_field(parent_context, field)
        pc = parent_context
        input = pc.input.respond_to?(:[]) ? pc.input[field] : nil
        source_location = Source::Location.next_field(pc.source_location, field)
        new(input,
            source_location: source_location,
            reference_location: pc.reference_location)
      end

      # Creates the context for a field that references another field
      #
      # @param  [Source::Location]  source_location
      # @param  [Source::Location]  reference_location
      # @return [Context]
      def self.resolved_reference(
        source_location:,
        reference_location:
      )
        new(source_location.data,
            source_location: source_location,
            reference_location: reference_location)
      end

      attr_reader :input, :source_location, :reference_location

      # @param  [Object]                  input
      # @param  [Source::Location]        source_location
      # @param  [Source::Location, nil]   reference_location
      def initialize(input,
                     source_location:,
                     reference_location: nil)
        @input = input
        @source_location = source_location
        @reference_location = reference_location
      end

      # @return [Boolean]
      def ==(other)
        input == other.input &&
          source_location == other.source_location &&
          reference_location == other.reference_location
      end

      # @return [Source]
      def source
        source_location.source
      end

      # @param  [String]              reference
      # @param  [Object, Map, Array]  factory
      # @return [Source::ResolvedReference]
      def resolve_reference(reference, factory)
        source.resolve_reference(reference, factory, self)
      end

      # Used to show when an recursive reference loop has begun
      #
      # @return [Boolean]
      def self_referencing?
        source_location == reference_location
      end

      def inspect
        %{#{self.class.name}(source_location: #{source_location}, } +
          %{reference_location: #{reference_location})}
      end

      def location_summary
        source_location.to_s
      end

      def to_s
        location_summary
      end
    end
  end
end
