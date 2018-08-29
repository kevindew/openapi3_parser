# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  # Document is the root construct of a created OpenAPI Document and can be
  # used to navigate the contents of a document or to check it's validity.
  #
  # @attr_reader  [String]        openapi_version
  # @attr_reader  [Source]        root_source
  # @attr_reader  [Array<String>] warnings
  class Document
    extend Forwardable
    include Enumerable

    attr_reader :openapi_version, :root_source, :warnings

    # A collection of the openapi versions that are supported
    SUPPORTED_OPENAPI_VERSIONS = %w[3.0].freeze

    # The version of OpenAPI that will be used by default for
    # validation/construction
    DEFAULT_OPENAPI_VERSION = "3.0"

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
    # @!method keys
    #   Access keys of the root object
    def_delegators :root, :openapi, :info, :servers, :paths, :components,
                   :security, :tags, :external_docs, :extension, :[], :each,
                   :keys

    # @param [SourceInput] source_input
    def initialize(source_input)
      @reference_register = ReferenceRegister.new
      @root_source = Source.new(source_input, self, reference_register)
      @warnings = []
      @openapi_version = determine_openapi_version(root_source.data["openapi"])
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

    # Look up the resolved input for an address in the OpenAPI document,
    # resolved_input refers to the input with references resolevd and all
    # optional fields existing
    #
    # @param [Context::Pointer, String, Array]      pointer
    # @param [Context::Pointer, String, Array, nil] relative_to
    # @return anything
    def resolved_input_at(pointer, relative_to = nil)
      look_up_pointer(pointer, relative_to, factory.resolved_input)
    end

    # Look up a node at a particular location in the OpenAPI docuemnt
    #
    # Examples:
    #
    # document.node_at("#/components/schemas")
    # document.node_at(%w[components schemas])
    #
    # @param [Context::Pointer, String, Array]      pointer
    # @param [Context::Pointer, String, Array, nil] relative_to
    # @return anything
    def node_at(pointer, relative_to = nil)
      look_up_pointer(pointer, relative_to, root)
    end

    # @return [String]
    def inspect
      %{#{self.class.name}(openapi_version: #{openapi_version}, } +
        %{root_source: #{root_source.inspect})}
    end

    private

    attr_reader :reference_register, :built, :build_in_progress

    def look_up_pointer(pointer, relative_pointer, subject)
      merged_pointer = Context::Pointer.merge_pointers(relative_pointer,
                                                       pointer)
      CautiousDig.call(subject, *merged_pointer.segments)
    end

    def add_warning(text)
      @warnings << text
    end

    def build
      return if build_in_progress || built
      @build_in_progress = true
      context = Context.root(root_source.data, root_source)
      @factory = NodeFactory::Openapi.new(context)
      reference_register.freeze
      @warnings.freeze
      @build_in_progress = false
      @built = true
    end

    def determine_openapi_version(version)
      minor_version = (version || "").split(".").first(2).join(".")

      if SUPPORTED_OPENAPI_VERSIONS.include?(minor_version)
        minor_version
      elsif version
        add_warning(
          "Unsupported OpenAPI version (#{version}), treating as a " \
          "#{DEFAULT_OPENAPI_VERSION} document"
        )
        DEFAULT_OPENAPI_VERSION
      else
        add_warning(
          "Unspecified OpenAPI version, treating as a " \
          "#{DEFAULT_OPENAPI_VERSION} document"
        )
        DEFAULT_OPENAPI_VERSION
      end
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
