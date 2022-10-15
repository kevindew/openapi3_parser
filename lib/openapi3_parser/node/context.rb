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
    # rubocop:disable Metrics/ClassLength
    class Context
      # Create a context for the root of a document
      #
      # @param  [NodeFactory::Context]  factory_context
      # @return [Node::Context]
      def self.root(factory_context)
        document_location = Source::Location.new(factory_context.source, [])

        source_location = factory_context.source_location
        input_locations = input_location?(factory_context.input) ? [source_location] : []

        new(factory_context.input,
            document_location: document_location,
            source_locations: [source_location],
            input_locations: input_locations)
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

        input_locations = if input_location?(factory_context.input)
                            [factory_context.source_location]
                          else
                            []
                          end

        new(factory_context.input,
            document_location: document_location,
            source_locations: [factory_context.source_location],
            input_locations: input_locations)
      end

      # Create a context for a the a field that is the result of a reference
      #
      # @param  [Node::Context]         current_context
      # @param  [NodeFactory::Context]  reference_factory_context
      # @return [Node::Context]
      def self.resolved_reference(current_context, reference_factory_context)
        input_locations = if input_location?(reference_factory_context.input)
                            current_context.input_locations + [reference_factory_context.source_location]
                          else
                            current_context.input_locations
                          end

        input = merge_reference_input(current_context.input, reference_factory_context.input)
        new(input,
            document_location: current_context.document_location,
            source_locations: current_context.source_locations + [reference_factory_context.source_location],
            input_locations: input_locations)
      end

      def self.merge_reference_input(current_input, reference_input)
        can_merge = reference_input.respond_to?(:merge) && current_input.respond_to?(:merge)

        return reference_input unless can_merge

        input = reference_input.merge(current_input)
        input.delete("$ref")
        input
      end

      def self.input_location?(input)
        return true unless input.respond_to?(:keys)

        input.keys != ["$ref"]
      end

      attr_reader :input, :document_location, :source_locations, :input_locations

      # @param                              input
      # @param  [Source::Location]          document_location
      # @param  [Array<Source::Location>]   source_locations
      # @param  [Array<Source::Location>]   input_locations
      def initialize(input, document_location:, source_locations:, input_locations:)
        @input = input
        @document_location = document_location
        @source_locations = source_locations
        @input_locations = input_locations
      end

      # @param  [Context] other
      # @return [Boolean]
      def ==(other)
        document_location == other.document_location &&
          source_locations == other.source_locations &&
          same_data_inputs?(other)
      end

      # Check that contexts are the same without concern for document location
      #
      # @param  [Context] other
      # @return [Boolean]
      def same_data_inputs?(other)
        input == other.input &&
          input_locations == other.input_locations
      end

      # The OpenAPI document associated with this context
      #
      # @return [Document]
      def document
        document_location.source.document
      end

      # The source files used to provide the data for this node
      #
      # @return [Array<Source>]
      def sources
        [source_locations].map(&:source)
      end

      # The source files used to provide the input for this node
      #
      # @return [Array<Source>]
      def input_sources
        [input_locations].map(&:source)
      end

      # @return [String]
      def inspect
        %{#{self.class.name}(document_location: #{document_location}, } +
          %{input_locations: #{input_locations.join(', ')})}
      end

      # A string representing the location of the node
      #
      # @return [String]
      def location_summary
        summary = document_location.to_s

        if input_locations.length > 1 || document_location != input_locations.first
          summary += " (#{input_locations.join(', ')})"
        end

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

      # Returns the version of OpenAPI being used
      #
      # @return [String]
      def openapi_version
        document.openapi_version
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
