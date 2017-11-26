# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/document"

module Helpers
  module Context
    def create_context(input, document_input: {}, namespace: [])
      Openapi3Parser::Context.new(
        input: input,
        namespace: namespace,
        document: Openapi3Parser::Document.new(document_input)
      )
    end
  end
end
