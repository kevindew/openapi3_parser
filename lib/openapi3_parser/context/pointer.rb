# frozen_string_literal: true

require "cgi"

module Openapi3Parser
  class Context
    # A class to decorate the array of fields that make up a pointer and
    # provide common means to convert it into different representations.
    class Pointer
      def self.from_fragment(fragment)
        fragment = fragment[1..-1] if fragment.start_with?("#")
        root = fragment[0] == "/"
        segments = fragment.split("/").map do |part|
          next if part == ""
          unescaped = CGI.unescape(part.gsub("%20", "+"))
          unescaped =~ /\A\d+\z/ ? unescaped.to_i : unescaped
        end
        new(segments.compact, root)
      end

      attr_reader :segments, :root

      # @param [::Array] segments
      # @param [Boolean] root
      def initialize(segments, root = true)
        @segments = segments.freeze
        @root = root
      end

      def ==(other)
        segments == other.segments
      end

      def fragment
        fragment = segments.map { |s| CGI.escape(s.to_s).gsub("+", "%20") }
                           .join("/")
        "#" + (root ? fragment.prepend("/") : fragment)
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
