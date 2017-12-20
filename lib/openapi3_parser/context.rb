# frozen_string_literal: true

module Openapi3Parser
  class Context
    attr_reader :input, :namespace, :source, :document, :parent

    def initialize(input:, namespace: [], source:, document:, parent: nil)
      @input = input
      @namespace = namespace.freeze
      @source = source
      @document = document
      @parent = parent
    end

    def self.root(input, source, document)
      new(input: input, source: source, document: document)
    end

    def stringify_namespace
      return "root" if namespace.empty?
      namespace
        .map { |i| i.to_s.include?("/") ? %("#{i}") : i }
        .join("/")
    end

    def next_namespace(segment, next_input = nil)
      next_input ||= input.nil? ? nil : input[segment]
      self.class.new(
        input: next_input,
        namespace: namespace + [segment],
        source: source,
        document: document,
        parent: self
      )
    end

    def resolve_reference
      source.resolve_reference(input["$ref"]) do |resolved_input, namespace|
        # @TODO track reference for cyclic depenendies
        next_context = resolved_reference(resolved_input, namespace)
        yield(next_context)
      end
    end

    def register_reference(given_reference, factory)
      source.register_reference(
        given_reference,
        factory,
        self
      )
    end

    def reference_namespace(input, namespace)
      self.class.new(
        input: input,
        namespace: namespace,
        source: source,
        document: document,
        parent: parent
      )
    end

    private

    def resolved_reference(input, namespace)
      self.class.new(
        input: input,
        namespace: namespace,
        source: source,
        document: document,
        parent: parent
      )
    end
  end
end
