# frozen_string_literal: true

require "openapi3_parser/context"
require "openapi3_parser/document/reference_register"
require "openapi3_parser/error"
require "openapi3_parser/node_factories/openapi"
require "openapi3_parser/source"
require "openapi3_parser/validation/error_collection"

require "forwardable"

module Openapi3Parser
  # Document is the root construct of a created OpenAPI Document and can be
  # used to navigate the contents of a document or to check it's validity.
  #
  # @attr_reader  [Source] root_source
  class Document
    extend Forwardable
    include Enumerable

    attr_reader :root_source

    # @!method valid?
    #   Whether this OpenAPI document has any validation issues or not. See
    #   #errors to access the errors
    #
    #   @return [Boolean]
    def_delegator :factory, :valid?

    # @!method openapi
    #   The value of the openapi version field for this document
    #   @see Node::Openapi#openapi
    #   @return [String]
    # @!method info
    #   The value of the info field on the OpenAPI document
    #   @see Node::Openapi#info
    #   @return [Node::Info]
    # @!method servers
    #   The value of the servers field on the OpenAPI document
    #   @see Node::Openapi#servers
    #   @return [Node::Array<Node::Server>]
    # @!method paths
    #   The value of the paths field on the OpenAPI document
    #   @see Node::Openapi#paths
    #   @return [Node::Paths]
    # @!method components
    #   The value of the components field on the OpenAPI document
    #   @see Node::Openapi#components
    #   @return [Node::Components]
    # @!method security
    #   The value of the security field on the OpenAPI document
    #   @see Node::Openapi#security
    #   @return [Node::Array<Node::SecurityRequirement>]
    # @!method tags
    #   The value of the tags field on the OpenAPI document
    #   @see Node::Openapi#tags
    #   @return [Node::Array<Node::Tag>]
    # @!method external_docs
    #   The value of the external_docs field on the OpenAPI document
    #   @see Node::Openapi#external_docs
    #   @return [Node::ExternalDocumentation]
    # @!method extension
    #   Look up an extension field provided for the root object of the document
    #   @see Node::Object#extension
    #   @return [Hash, Array, Numeric, String, true, false, nil]
    # @!method []
    #   Look up an attribute on the root of the OpenAPI document by String
    #   or Symbol
    #   @see Node::Object#[]
    #   @return Object
    # @!method each
    #   Iterate through the attributes of the root object
    #   @see Node::Object#each
    def_delegators :root, :openapi, :info, :servers, :paths, :components,
                   :security, :tags, :external_docs, :extension, :[], :each

    # @param [SourceInput] source_input
    def initialize(source_input)
      @reference_register = ReferenceRegister.new
      @root_source = Source.new(source_input, self, reference_register)
      @build_in_progress = false
      @built = false
    end

    # @return [Node::Openapi]
    def root
      factory.node
    end

    # All the additional sources that have been referenced as part of loading
    # the OpenAPI document
    #
    # @return [Array<Source>]
    def reference_sources
      build unless built
      reference_register.sources
    end

    # All of the sources involved in this OpenAPI document
    #
    # @return [Array<Source>]
    def sources
      [root_source] + reference_sources
    end

    # Any validation errors that are present on the OpenAPI document
    #
    # @return [Validation::ErrorCollection]
    def errors
      reference_factories.inject(factory.errors) do |memo, f|
        Validation::ErrorCollection.combine(memo, f.errors)
      end
    end

    # Look up whether an instance of SourceInput is already a known source
    # for this document.
    #
    # @param [SourceInput] source_input
    # @return [Source, nil]
    def source_for_source_input(source_input)
      sources.find { |source| source.source_input == source_input }
    end

    private

    attr_reader :reference_register, :built, :build_in_progress

    def build
      return if build_in_progress || built
      @build_in_progress = true
      context = Context.root(root_source.data, root_source)
      @factory = NodeFactories::Openapi.new(context)
      reference_register.freeze
      @build_in_progress = false
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
