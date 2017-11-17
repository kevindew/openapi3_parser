# frozen_string_literal: true

module OpenapiParser
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
        .map { |i| i.include?("/") ? %("#{i}") : i }
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

    def possible_reference(input)
      return yield(input, self) unless input["$ref"]

      document.resolve_reference(input["$ref"]) do |resolved_input|
        # @TODO track reference for cyclic depenendies
        yield(resolved_input, self)
      end
    end
  end
end
