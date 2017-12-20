# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/error"
require "openapi3_parser/source"
require "openapi3_parser/node_factories/openapi"

require "forwardable"

module Openapi3Parser
  class Document
    extend Forwardable

    attr_reader :root_source

    def_delegators :factory, :valid?, :errors
    def_delegators :root, :openapi, :info, :servers, :paths, :components,
                   :security, :tags, :external_docs, :extension, :[], :each

    def initialize(source_input)
      @root_source = Source.new(source_input, self)
    end

    def root
      factory.node
    end

    private

    def factory
      @factory ||= begin
                     context = Context.root(root_source.data, root_source, self)
                     NodeFactories::Openapi.new(context)
                   end
    end
  end
end
