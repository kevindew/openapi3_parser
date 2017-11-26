# frozen_string_literal: true

require "openapi_parser/context"
require "openapi_parser/error"
require "openapi_parser/node_factories/openapi"

require "forwardable"

module OpenapiParser
  class Document
    extend Forwardable

    attr_reader :input

    def_delegators :factory, :valid?, :errors
    def_delegators :root, :openapi, :info, :servers, :paths, :components,
                   :security, :tags, :external_docs, :extension, :[], :each

    def initialize(input)
      @input = input
    end

    def root
      factory.node
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

      yield(result, parts)
    end

    private

    def factory
      @factory ||= NodeFactories::Openapi.new(Context.root(input, self))
    end
  end
end
