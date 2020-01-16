# frozen_string_literal: true

require "forwardable"

module Openapi3Parser
  class Source
    # Class used to represent a location within an OpenAPI document.
    # It contains a source, which is the source file/data used for the contents
    # and the pointer which indicates where in the object like file the data is
    class Location
      extend Forwardable

      def self.next_field(location, field)
        new(location.source, location.pointer.segments + [field])
      end

      def_delegators :pointer, :root?
      attr_reader :source, :pointer

      # @param [Openapi3Parser::Source] source
      # @param [::Array] pointer_segments
      def initialize(source, pointer_segments)
        @source = source
        @pointer = Pointer.new(pointer_segments.freeze)
      end

      def ==(other)
        return false unless other.instance_of?(self.class)

        source == other.source && pointer == other.pointer
      end

      def to_s
        source.relative_to_root + pointer.fragment
      end

      def data
        source.data_at_pointer(pointer.segments)
      end

      def pointer_defined?
        source.has_pointer?(pointer.segments)
      end

      def source_available?
        source.available?
      end

      def inspect
        %{#{self.class.name}(source: #{source.inspect}, pointer: #{pointer})}
      end
    end
  end
end
