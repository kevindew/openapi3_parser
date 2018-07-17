# frozen_string_literal: true

require "cgi"

module Openapi3Parser
  class Context
    # A class to decorate the array of fields that make up a pointer and
    # provide common means to convert it into different representations.
    class Pointer
      attr_reader :segments

      # @param [::Array] segments
      def initialize(segments)
        @segments = segments.freeze
      end

      def ==(other)
        segments == other.segments
      end

      def fragment
        segments.map { |s| CGI.escape(s.to_s).gsub("+", "%20") }
                .join("/")
                .prepend("#/")
      end

      def to_s
        fragment
      end

      def inspect
        %{#{self.class.name}(segments: #{segments}, fragment: "#{fragment}")}
      end
    end
  end
end
