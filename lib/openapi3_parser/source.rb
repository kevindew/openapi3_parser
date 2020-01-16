# frozen_string_literal: true

module Openapi3Parser
  # Represents a source of data used to produce the OpenAPI document. Documents
  # which do not have any references to external files will only have a single
  # source
  #
  # @attr_reader [SourceInput]                  source_input
  #   The source input which provides the data
  # @attr_reader [Document]                     document
  #   The document that this source is associated with
  # @attr_reader [Document::ReferenceRegistry]  reference_registry
  #   An object that tracks factories for all references
  # @attr_reader [Source, nil]                  parent
  #   Set to a Source if this source was created due to a reference within
  #   a different Source
  class Source
    attr_reader :source_input, :document, :reference_registry, :parent

    # @param  [SourceInput]                   source_input
    # @param  [Document]                      document
    # @param  [Document::ReferenceRegistry]   reference_registry
    # @param  [Source, nil]                   parent
    def initialize(source_input, document, reference_registry, parent = nil)
      @source_input = source_input
      @document = document
      @reference_registry = reference_registry
      @parent = parent
    end

    # The data from the source
    def data
      @data ||= normalize_data(source_input.contents)
    end

    # @see SourceInput#available?
    def available?
      source_input.available?
    end

    # Whether this is the root source of a document
    def root?
      document.root_source == self
    end

    def resolve_reference(given_reference,
                          unbuilt_factory,
                          context,
                          recursive: false)
      reference = Reference.new(given_reference)
      resolved_source = resolve_source(reference)
      source_location = Source::Location.new(resolved_source,
                                             reference.json_pointer)

      unless recursive
        reference_registry.register(unbuilt_factory,
                                    source_location,
                                    context)
      end

      ResolvedReference.new(
        source_location: source_location,
        object_type: unbuilt_factory.object_type,
        reference_registry: reference_registry
      )
    end

    # Access/create the source object for a reference
    #
    # @param  [Reference] reference
    # @return [Source]
    def resolve_source(reference)
      if reference.only_fragment?
        # I found the spec wasn't fully clear on expected behaviour if a source
        # references a fragment that doesn't exist in it's current document
        # and just the root source. I'm assuming to be consistent with URI a
        # fragment only references the current JSON document. This could be
        # incorrect though.
        self
      else
        next_source_input = source_input.resolve_next(reference)
        source = document.source_for_source_input(next_source_input)
        source || self.class.new(next_source_input,
                                 document,
                                 reference_registry,
                                 self)
      end
    end

    # Access the data in a source at a particular pointer
    #
    # @param  [Array] json_pointer  An array of segments of a JSON pointer
    # @return [Object]
    def data_at_pointer(json_pointer)
      return data if json_pointer.empty?

      data.dig(*json_pointer) if data.respond_to?(:dig)
    end

    # Whether the source has data at the particular pointer
    def has_pointer?(json_pointer) # rubocop:disable Naming/PredicateName
      !data_at_pointer(json_pointer).nil?
    end

    # @return [String]
    def relative_to_root
      return "" if root?

      source_input.relative_to(document.root_source.source_input)
    end

    def ==(other)
      source_input == other.source_input && document == other.document
    end

    # return [String]
    def inspect
      %{#{self.class.name}(input: #{source_input})}
    end

    private

    def normalize_data(input)
      normalized = if input.respond_to?(:keys)
                     input.each_with_object({}) do |(key, value), memo|
                       memo[key.to_s.freeze] = normalize_data(value)
                     end
                   elsif input.respond_to?(:map)
                     input.map { |v| normalize_data(v) }
                   else
                     input
                   end

      normalized.freeze
    end
  end
end
