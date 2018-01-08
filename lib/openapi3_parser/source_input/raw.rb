# frozen_string_literal: true

require "openapi3_parser/source_input"
require "openapi3_parser/source_input/string_parser"
require "openapi3_parser/source_input/resolve_next"

module Openapi3Parser
  class SourceInput
    class Raw < SourceInput
      attr_reader :raw_input, :base_url, :working_directory

      def initialize(raw_input, base_url = nil, working_directory = nil)
        @raw_input = raw_input
        @base_url = base_url
        working_directory ||= resolve_working_directory
        @working_directory = ::File.absolute_path(working_directory)
        initialize_contents
      end

      def resolve_next(reference)
        ResolveNext.call(reference,
                         self,
                         base_url: base_url,
                         working_directory: working_directory)
      end

      def ==(other)
        return false unless other.instance_of?(self.class)
        raw_input == other.raw_input &&
          base_url == other.base_url &&
          working_directory == other.working_directory
      end

      private

      def resolve_working_directory
        if raw_input.respond_to?(:path)
          ::File.dirname(raw_input)
        else
          Dir.pwd
        end
      end

      def parse_contents
        return raw_input if raw_input.respond_to?(:keys)
        StringParser.call(
          input_to_string(raw_input),
          raw_input.respond_to?(:path) ? ::File.basename(raw_input.path) : nil
        )
      end

      def input_to_string(input)
        return input.read if input.respond_to?(:read)
        return input.to_s if input.respond_to?(:to_s)
        input
      end
    end
  end
end
