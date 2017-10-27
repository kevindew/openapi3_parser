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
        .map { |i| i.include("/") ?  %{"#{i}"} : i }
        .join("/")
    end

    def next_namespace(segment)
      self.class.new(document, namespace + [segment.to_s])
    end
  end
end
