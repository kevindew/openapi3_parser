# frozen_string_literal: true

require "openapi3_parser/error"

module Openapi3Parser
  class SourceInput
    attr_reader :access_error, :parse_error

    def available?
      access_error.nil? && parse_error.nil?
    end

    def resolve_next(_reference); end

    def contents
      raise access_error if access_error
      raise parse_error if parse_error
      @contents
    end

    private

    def initialize_contents
      return if access_error
      @contents = parse_contents
    rescue ::StandardError => e
      @parse_error = Error::UnparsableInput.new(e.message)
    end
  end
end
