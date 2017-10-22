# frozen_string_literal: true

module OpenapiParser
  class Factory
    def initialize(input, working_directory:)
      # @TODO maybe we'll recursively clone and freeze this input?
      @input = input
      @working_directory = working_directory
    end

    def document
      Node::OpenapiParser::Factory.new(input, self)
    end

    private

    attr_reader :input, :working_directory
  end
end
