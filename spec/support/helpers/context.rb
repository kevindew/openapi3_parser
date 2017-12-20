# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/document"
require "openapi3_parser/source_input/raw"

module Helpers
  module Context
    def create_context(input, document_input: {}, namespace: [])
      source_input = Openapi3Parser::SourceInput::Raw.new(document_input)
      document = Openapi3Parser::Document.new(source_input)
      Openapi3Parser::Context.new(
        input: input,
        namespace: namespace,
        source: document.root_source,
        document: document
      )
    end
  end
end
