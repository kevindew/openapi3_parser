# frozen_string_literal: true

require "openapi_parser/nodes/openapi"
require "openapi_parser/context"

module OpenapiParser
  class Document
    attr_reader :input, :root

    def initialize(input)
      @input = input
      @root = Nodes::Openapi.new(input, Context.root(self))
    end
  end
end
