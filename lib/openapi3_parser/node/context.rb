# frozen_string_literal: true

module Openapi3Parser
  module Node
    # This class is used to specify the data and source information for a
    # Node, for every node there is a different context to represent it's
    # place within the document.
    class Context
      # Create a context for the root of a document
      #
      # @param  [NodeFactory::Context]  factory_context
      # @return [Node::Context]
      def self.root(factory_context)
        location = Source::Location.new(factory_context.source, [])
        new(factory_context.input,
            document_location: location,
            source_location: factory_context.source_location)
      end

      # Create a context for the child of a previous context
      #
      # @param  [Node::Context]         parent_context
      # @param  [String]                field
      # @param  [NodeFactory::Context]  factory_context
      # @return [Node::Context]
      def self.next_field(parent_context, field, factory_context)
        document_location = Source::Location.next_field(
          parent_context.document_location,
          field
        )

        new(factory_context.input,
            document_location: document_location,
            source_location: factory_context.source_location,
            reference_location: parent_context.reference_location)
      end

      # Create a context for a the a field that is the result of a reference
      #
      # @param  [Node::Context]         current_context
      # @param  [NodeFactory::Context]  reference_factory_context
      # @return [Node::Context]
      def self.resolved_reference(current_context, reference_factory_context)
        reference_locations = reference_factory_context.reference_locations

        new(reference_factory_context.input,
            document_location: current_context.document_location,
            source_location: reference_factory_context.source_location,
            reference_location: reference_locations.first)
      end

      attr_reader :input,
                  :document_location,
                  :source_location,
                  :reference_location

      # @param                           input
      # @param  [Source::Location]       document_location
      # @param  [Source::Location]       source_location
      # @param  [Source::Location, nil]  reference_location
      def initialize(input,
                     document_location:,
                     source_location:,
                     reference_location: nil)
        @input = input
        @document_location = document_location
        @source_location = source_location
        @reference_location = reference_location
      end

      # @return [Boolean]
      def ==(other)
        input == other.input &&
          document_location == other.document_location &&
          source_location == other.source_location &&
          reference_location == other.reference_location
      end

      # @return [Document]
      def document
        document_location.source.document
      end

      # @return [Source]
      def source
        source_location.source
      end

      def inspect
        %{#{self.class.name}(document_location: #{document_location}, } +
          %{source_location: #{source_location}), reference_location: } +
          %{#{reference_location})}
      end

      def location_summary
        summary = document_location.to_s

        if document_location != source_location
          summary += " (#{source_location})"
        end

        summary
      end

      def to_s
        location_summary
      end

      def resolved_input
        document.resolved_input_at(document_location.pointer)
      end

      def node
        document.node_at(document_location.pointer)
      end
    end
  end
end
