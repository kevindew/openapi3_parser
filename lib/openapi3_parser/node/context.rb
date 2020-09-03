# frozen_string_literal: true

module Openapi3Parser
  module Node
    # This class is used to specify the data and source information for a
    # Node, for every node there is a different context to represent it's
    # place within the document.
    #
    # @attr_reader  [Any]               input             The raw data that was
    #                                                     used to build the
    #                                                     node
    # @attr_reader  [Source::Location]  document_location The location in the
    #                                                     root source of this
    #                                                     node
    # @attr_reader  [Source::Location]  source_location   The location in a
    #                                                     source file of this
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
            source_location: factory_context.source_location)
      end

      # Create a context for a the a field that is the result of a reference
      #
      # @param  [Node::Context]         current_context
      # @param  [NodeFactory::Context]  reference_factory_context
      # @return [Node::Context]
      def self.resolved_reference(current_context, reference_factory_context)
        new(reference_factory_context.input,
            document_location: current_context.document_location,
            source_location: reference_factory_context.source_location)
      end

      attr_reader :input, :document_location, :source_location

      # @param                           input
      # @param  [Source::Location]       document_location
      # @param  [Source::Location]       source_location
      def initialize(input, document_location:, source_location:)
        @input = input
        @document_location = document_location
        @source_location = source_location
      end

      # @param  [Context] other
      # @return [Boolean]
      def ==(other)
        document_location == other.document_location &&
          same_data_and_source?(other)
      end

      # Check that contexts are the same without concern for document location
      #
      # @param  [Context] other
      # @return [Boolean]
      def same_data_and_source?(other)
        input == other.input &&
          source_location == other.source_location
      end

      # The OpenAPI document associated with this context
      #
      # @return [Document]
      def document
        document_location.source.document
      end

      # The source file used to provide the data for this node
      #
      # @return [Source]
      def source
        source_location.source
      end

      # @return [String]
      def inspect
        %{#{self.class.name}(document_location: #{document_location}, } +
          %{source_location: #{source_location})}
      end

      # A string representing the location of the node
      #
      # @return [String]
      def location_summary
        summary = document_location.to_s

        summary += " (#{source_location})" if document_location != source_location

        summary
      end

      # (see #location_summary)
      def to_s
        location_summary
      end

      # Used to return the data at this document location with all references
      # resolved and optional fields populated with defaults
      #
      # @return [Any]
      def resolved_input
        document.resolved_input_at(document_location.pointer)
      end

      # Return the node for this context
      #
      # @return [Node::Object, Node::Map, Node::Array]
      def node
        document.node_at(document_location.pointer)
      end

      # Look up a node at a particular location in the OpenAPI docuemnt based
      # on the relative position in the document of this context
      #
      # Examples:
      #
      # context.relative_node("#schemas")
      # context.relative_node(%w[..])
      #
      # @param [Source::Pointer, String, Array] pointer
      # @return anything
      def relative_node(pointer)
        document.node_at(pointer, document_location.pointer)
      end

      # Return the node that is the parent node for the node at this context
      #
      # @return [Node::Object, Node::Map, Node::Array, nil]
      def parent_node
        return if document_location.root?

        relative_node("#..")
      end
    end
  end
end
