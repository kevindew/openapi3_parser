# frozen_string_literal: true

module Openapi3Parser
  # Context is a construct used in both the node factories and the nodes
  # themselves. It is used to represent the data, and the source of it, that
  # a node is associated with. It also acts as a bridge between a node/node
  # factory and associated document.
  #
  # @attr_reader                            input
  # @attr_reader  [Context::Location]       document_location
  # @attr_reader  [Context::Location, nil]  source_location
  # @attr_reader  [Context, nil]            referenced_by
  class Context
    # Create a context for the root of a document
    # @return [Context]
    def self.root(input, source)
      location = Location.new(source, [])
      new(input, document_location: location)
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
      new(input,
          document_location: Location.next_field(pc.document_location, field),
          source_location: Location.next_field(pc.source_location, field),
          referenced_by: pc.referenced_by)
    end

    # Convert a context into one that knows that is a reference
    #
    # @param  [Context] current_context
    # @return [Context]
    def self.as_reference(current_context)
      new(current_context.input,
          document_location: current_context.document_location,
          source_location: current_context.source_location,
          referenced_by: current_context.referenced_by,
          is_reference: true)
    end

    # Creates the context for a field that is referenced by a context.
    # In this scenario the context of the document is the same but we are in
    # a different part of the source file, or even a different source file
    #
    # @param  [Context] referencer_context
    # @param            input
    # @param  [Source]  source
    # @param  [::Array] pointer_segments
    # @return [Context]
    def self.reference_field(referencer_context,
                             input:,
                             source:,
                             pointer_segments:)
      new(input,
          document_location: referencer_context.document_location,
          source_location: Location.new(source, pointer_segments),
          referenced_by: referencer_context)
    end

    attr_reader :input, :document_location, :source_location, :referenced_by

    # @param                            input
    # @param  [Context::Location]       document_location
    # @param  [Context::Location, nil]  source_location
    # @param  [Context, nil]            referenced_by
    # @param  [Boolean]                 is_reference
    def initialize(input,
                   document_location:,
                   source_location: nil,
                   referenced_by: nil,
                   is_reference: false)
      @input = input
      @document_location = document_location
      @source_location = source_location || document_location
      @referenced_by = referenced_by
      @is_reference = is_reference
    end

    # @return [Boolean]
    def ==(other)
      input == other.input &&
        document_location == other.document_location &&
        source_location == other.source_location &&
        referenced_by == other.referenced_by
    end

    # @return [Document]
    def document
      document_location.source.document
    end

    # @return [Source]
    def source
      source_location.source
    end

    # @return [Source::ReferenceResolver]
    def register_reference(reference, factory)
      source.register_reference(reference, factory, self)
    end

    # @deprecated
    def namespace
      document_location.pointer.segments
    end

    # @return [Boolean]
    def reference?
      @is_reference
    end

    def inspect
      %{#{self.class.name}(document_location: #{document_location}, } +
        %{source_location: #{source_location}), referenced_by: } +
        %{#{referenced_by})}
    end

    def location_summary
      summary = document_location.to_s
      summary += " (#{source_location})" if document_location != source_location
      summary
    end

    def to_s
      location_summary
    end

    def resolved_input
      # The resolved input for a reference is at the segment before the
      # reference
      pointer = if reference?
                  document_location.pointer.segments[0...-1]
                else
                  document_location.pointer
                end

      document.resolved_input_at(pointer)
    end

    def node
      # The created node for a reference is at the segment before the
      # reference
      pointer = if reference?
                  document_location.pointer.segments[0...-1]
                else
                  document_location.pointer
                end

      document.node_at(pointer)
    end
  end
end
