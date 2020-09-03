# frozen_string_literal: true

module Openapi3Parser
  module Validators
    # This validates that the keys of an object match the format of those
    # defined for a Components node.
    # As defined: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#components-object
    class ComponentKeys
      REGEX = /\A[a-zA-Z0-9.\-_]+\Z/.freeze

      def self.call(input)
        invalid = input.keys.reject { |key| REGEX.match(key) }
        "Contains invalid keys: #{invalid.join(', ')}" unless invalid.empty?
      end
    end
  end
end
