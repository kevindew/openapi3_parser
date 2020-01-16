# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class Reference
      def initialize(given_reference)
        @given_reference = given_reference
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= Array(build_errors)
      end

      private

      attr_reader :given_reference

      def build_errors
        return "Expected a string" unless given_reference.is_a?(String)

        begin
          uri = URI.parse(given_reference)
        rescue URI::Error
          return "Could not parse as a URI"
        end
        check_fragment(uri) || []
      end

      def check_fragment(uri)
        return if uri.fragment.nil? || uri.fragment.empty?

        first_char = uri.fragment[0]

        "Invalid JSON pointer, expected a root slash" if first_char != "/"
      end
    end
  end
end
