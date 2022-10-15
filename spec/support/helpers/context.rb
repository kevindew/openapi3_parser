# frozen_string_literal: true

module Helpers
  module Context
    def create_node_factory_context(input,
                                    document_input: {},
                                    document: nil,
                                    pointer_segments: [],
                                    reference_pointer_fragments: [])
      source_input = Openapi3Parser::SourceInput::Raw.new(document_input)
      document ||= Openapi3Parser::Document.new(source_input)
      location = Openapi3Parser::Source::Location.new(
        document.root_source,
        pointer_segments
      )

      reference_locations = reference_pointer_fragments.map do |fragment|
        Openapi3Parser::Source::Location.new(
          document.root_source,
          Openapi3Parser::Source::Pointer.from_fragment(fragment).segments
        )
      end

      Openapi3Parser::NodeFactory::Context.new(
        input,
        source_location: location,
        reference_locations: reference_locations
      )
    end

    def node_factory_context_to_node_context(node_factory_context)
      input = node_factory_context.input
      source_location = node_factory_context.source_location
      input_locations = Openapi3Parser::Node::Context.input_location?(input) ? [source_location] : []

      Openapi3Parser::Node::Context.new(input,
                                        document_location: source_location,
                                        source_locations: [source_location],
                                        input_locations: input_locations)
    end

    def create_node_context(input, document_input: {}, pointer_segments: [])
      source_input = Openapi3Parser::SourceInput::Raw.new(document_input)
      document = Openapi3Parser::Document.new(source_input)
      location = Openapi3Parser::Source::Location.new(document.root_source, pointer_segments)

      input_locations = Openapi3Parser::Node::Context.input_location?(input) ? [location] : []
      Openapi3Parser::Node::Context.new(input,
                                        document_location: location,
                                        source_locations: [location],
                                        input_locations: input_locations)
    end
  end
end
