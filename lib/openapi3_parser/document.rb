# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/document/reference_register"
require "openapi3_parser/error"
require "openapi3_parser/node_factories/openapi"
require "openapi3_parser/source"
require "openapi3_parser/validation/error_collection"

require "forwardable"

module Openapi3Parser
  class Document
    extend Forwardable

    attr_reader :root_source

    def_delegators :factory, :valid?
    def_delegators :root, :openapi, :info, :servers, :paths, :components,
                   :security, :tags, :external_docs, :extension, :[], :each

    def initialize(source_input)
      @reference_register = ReferenceRegister.new
      @root_source = Source.new(source_input, self, reference_register)
      @built = false
    end

    def root
      factory.node
    end

    def reference_sources
      build unless built
      reference_register.sources
    end

    def sources
      [root_source] + reference_sources
    end

    def errors
      error_collection = Validation::ErrorCollection.new
      error_collection.merge(factory.errors)
      reference_factories.each { |f| error_collection.merge(f.errors) }
      error_collection
    end

    def source_for_source_input(source_input)
      sources = [root_source] + reference_register.sources
      sources.find { |source| source.source_input == source_input }
    end

    private

    attr_reader :reference_register, :built

    def build
      context = Context.root(root_source.data, root_source)
      @factory = NodeFactories::Openapi.new(context)
      reference_register.freeze
      @built = true
    end

    def factory
      build unless built
      @factory
    end

    def reference_factories
      build unless built
      reference_register.factories
    end
  end
end
