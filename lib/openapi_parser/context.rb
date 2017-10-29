# frozen_string_literal: true

module OpenapiParser
  class Context
    attr_reader :document, :namespace

    def initialize(document, namespace)
      @document = document
      @namespace = namespace.freeze
    end

    def self.root(document)
      new(document, [])
    end

    def stringify_namespace
      return "root" if namespace.empty?
      namespace
        .map { |i| i.include?("/") ? %("#{i}") : i }
        .join("/")
    end

    def next_namespace(segment)
      self.class.new(document, namespace + [segment.to_s])
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
