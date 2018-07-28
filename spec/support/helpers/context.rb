# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/context/location"
require "openapi3_parser/document"
require "openapi3_parser/source_input/raw"

module Helpers
  module Context
    # rubocop:disable Metrics/ParameterLists
    def create_context(input,
                       document_input: {},
                       document: nil,
                       pointer_segments: [],
                       referenced_by: nil,
                       is_reference: false)
      source_input = Openapi3Parser::SourceInput::Raw.new(document_input)
      document ||= Openapi3Parser::Document.new(source_input)
      location = Openapi3Parser::Context::Location
      document_location = location.new(document.root_source, pointer_segments)
      Openapi3Parser::Context.new(input,
                                  document_location: document_location,
                                  referenced_by: referenced_by,
                                  is_reference: is_reference)
    end
    # rubocop:enable Metrics/ParameterLists

    def create_context_location(source_input,
                                document: nil,
                                pointer_segments: [])
      source = if !document
                 Openapi3Parser::Document.new(source_input).root_source
               else
                 Openapi3Parser::Source.new(
                   source_input,
                   document,
                   Openapi3Parser::Document::ReferenceRegister.new
                 )
               end

      Openapi3Parser::Context::Location.new(source, pointer_segments)
    end
  end
end
