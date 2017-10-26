# frozen_string_literal: true

require "openapi_parser/nodes/openapi"

module OpenapiParser
  class Document
    attr_reader :input, :root

    def initialize(input)
      @input = input
      @root = Nodes::Openapi.new(input, self, [])
    end
  end
end
