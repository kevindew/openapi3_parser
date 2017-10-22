# frozen_string_literal: true

module OpenapiParser
  module SnakeCase
    refine String do
      # From http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-underscore
      def snake_case
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end
    end
  end

  class Node
    using SnakeCase

    DEFAULT_OPENAPI_VERSION = "3.0"

    attr_reader :input, :openapi_version, :attributes, :extensions

    def initialize(input, openapi_version = DEFAULT_OPENAPI_VERSION)
      @input = input
      @openapi_version = openapi_version
      @attributes = build_nodes(input.dup)
      @extensions = extract_extensions(@attributes)
    end

    def [](value)
      attributes[value]
    end

    def extension(value)
      extensions[value]
    end

    private

    def build_nodes(input)
      input.each_with_object({}) do |(key, value), memo|
        method = "build_#{key.snake_case}_node".to_sym
        memo[key] = respond_to?(method) ? method.send(value) : value
      end
    end

    def extract_extensions(attributes)
      attributes.each_with_object({}) do |(key, value), memo|
        memo[Regexp.last_match[1]] = value if key =~ /^x-(.*)/
      end
    end
  end
end
