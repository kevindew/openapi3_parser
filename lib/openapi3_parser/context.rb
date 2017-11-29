# frozen_string_literal: true

module Openapi3Parser
  class Context
    attr_reader :input, :namespace, :document, :parent

    def initialize(input:, namespace: [], document:, parent: nil)
      @input = input
      @namespace = namespace.freeze
      @document = document
      @parent = parent
    end

    def self.root(input, document)
      new(input: input, document: document)
    end

    def stringify_namespace
      return "root" if namespace.empty?
      namespace
        .map { |i| i.to_s.include?("/") ? %("#{i}") : i }
        .join("/")
    end

    def next_namespace(segment, next_input = nil)
      next_input ||= input[segment]
      self.class.new(
        input: next_input,
        namespace: namespace + [segment],
        document: document,
        parent: self
      )
    end

    def resolve_reference
      document.resolve_reference(input["$ref"]) do |resolved_input, namespace|
        # @TODO track reference for cyclic depenendies
        next_context = resolved_reference(resolved_input, namespace)
        yield(next_context)
      end
    end

    private

    def resolved_reference(input, namespace)
      self.class.new(
        input: input,
        namespace: namespace,
        document: document,
        parent: parent
      )
    end
  end
end
