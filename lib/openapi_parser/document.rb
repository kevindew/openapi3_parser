# frozen_string_literal: true

require "openapi_parser/nodes/openapi"
require "openapi_parser/context"
require "openapi_parser/error"

module OpenapiParser
  class Document
    attr_reader :input

    def initialize(input)
      @input = input
    end

    def valid?
      true
    end

    def errors
      []
    end

    def root
      @root ||= Nodes::Openapi.new(input, Context.root(self))
    end

    def resolve_reference(reference)
      if reference[0..1] != "#/"
        raise Error, "Only anchor references are currently supported"
      end

      parts = reference.split("/").drop(1).map do |field|
        CGI.unescape(field.gsub("+", "%20"))
      end

      result = input.dig(*parts)
      raise Error, "Could not resolve reference #{reference}" unless result

      yield(result)
    end

    private

    def root_factory

    end
  end
end
