# frozen_string_literal: true

module Openapi3Parser
  module Validation
    class InputValidator
      attr_reader :callable

      def initialize(callable)
        @callable = callable
      end

      def call(validatable)
        error = callable.call(validatable.input)
        validatable.add_error(error) if error
      end
    end
  end
end
