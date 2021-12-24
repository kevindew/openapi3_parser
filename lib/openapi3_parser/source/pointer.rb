# frozen_string_literal: true

require "cgi"

module Openapi3Parser
  class Source
    # A class to decorate the array of fields that make up a pointer and
    # provide common means to convert it into different representations.
    class Pointer
      def self.from_fragment(fragment)
        fragment = fragment[1..] if fragment.start_with?("#")
        absolute = fragment[0] == "/"
        segments = fragment.split("/").map do |part|
          next if part == ""

          unescaped = CGI.unescape(part.gsub("%20", "+"))
          unescaped.match?(/\A\d+\z/) ? unescaped.to_i : unescaped
        end
        new(segments.compact, absolute: absolute)
      end

      def self.merge_pointers(base_pointer, new_pointer)
        MergePointers.call(base_pointer, new_pointer)
      end

      attr_reader :segments, :absolute

      # @param [::Array] segments
      # @param [Boolean] absolute
      def initialize(segments, absolute: true)
        @segments = segments.freeze
        @absolute = absolute
      end

      def ==(other)
        segments == other.segments
      end

      def fragment
        fragment = segments.map { |s| CGI.escape(s.to_s).gsub("+", "%20") }
                           .join("/")
        "##{absolute ? fragment.prepend('/') : fragment}"
      end

      def to_s
        fragment
      end

      def inspect
        %{#{self.class.name}(segments: #{segments}, fragment: "#{fragment}")}
      end

      def root?
        segments.empty?
      end

      class MergePointers
        private_class_method :new

        def self.call(*args)
          new(*args).call
        end

        def initialize(base_pointer, new_pointer)
          @base_pointer = create_pointer(base_pointer)
          @new_pointer = create_pointer(new_pointer)
        end

        def call
          return base_pointer if new_pointer.nil?
          return new_pointer if base_pointer.nil? || new_pointer.absolute

          merge_pointers(base_pointer, new_pointer)
        end

        private

        attr_reader :base_pointer, :new_pointer

        def create_pointer(pointer_like)
          case pointer_like
          when Pointer then pointer_like
          when ::Array then Pointer.new(pointer_like, absolute: false)
          when ::String then Pointer.from_fragment(pointer_like)
          when nil then nil
          else raise Openapi3Parser::Error, "Unexpected type for pointer"
          end
        end

        def merge_pointers(pointer_a, pointer_b)
          fragment_a = pointer_a.fragment.gsub(%r{\A#?/?}, "")
          fragment_b = pointer_b.fragment.gsub(%r{\A#?/?}, "")

          joined = File.expand_path("/#{fragment_a}/#{fragment_b}", "/")

          joined = joined[1..] unless pointer_a.absolute

          Pointer.from_fragment("##{joined}")
        end
      end
    end
  end
end
