# frozen_string_literal: true

module OpenapiParser
  class Factory
    def initialize(input, working_directory:)
      @input = input
      @working_directory = working_directory
    end

    def document
      Document.new
    end

    private

    attr_reader :input, :working_directory
  end
end
