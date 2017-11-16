# frozen_string_literal: true

require "openapi_parser/context"
require "openapi_parser/document"

module Helpers
  module Context
    def create_context(input, document_input: {}, namespace: [])
      OpenapiParser::Context.new(
        input: input,
        namespace: namespace,
        document: OpenapiParser::Document.new(document_input)
      )
    end
  end
end
