# frozen_string_literal: true

module OpenapiParser
  class Document
    attr_reader :input, :root

    def initialize(input)
      @input = input
      @root = Node::Openapi.new(input, self, [])
    end
  end
end
