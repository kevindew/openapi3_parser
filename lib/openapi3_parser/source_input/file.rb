# frozen_string_literal: true

require "openapi3_parser/source_input"
require "openapi3_parser/source_input/string_parser"
require "openapi3_parser/source_input/resolve_next"
require "openapi3_parser/error"

module Openapi3Parser
  class SourceInput
    # An input of a file on the file system
    #
    # @attr_reader [String] path              The absolute path to this file
    # @attr_reader [String] working_directory The abolsute path of the
    #                                         working directory to use when
    #                                         opening relative references to
    #                                         this file
    class File < SourceInput
      attr_reader :path, :working_directory

      # @param [String]       path              The path to the file to open
      #                                         as this source
      # @param [String, nil]  working_directory The path to the
      #                                         working directory to use, will
      #                                         be calculated from path if not
      #                                         provided
      def initialize(path, working_directory = nil)
        @path = ::File.absolute_path(path)
        working_directory ||= resolve_working_directory
        @working_directory = ::File.absolute_path(working_directory)
        initialize_contents
      end

      # @see SourceInput#resolve_next
      # @param  [Source::Reference] reference
      # @return [SourceInput]
      def resolve_next(reference)
        ResolveNext.call(reference, self, working_directory: working_directory)
      end

      # @see SourceInput#other
      # @param  [SourceInput] other
      # @return [Boolean]
      def ==(other)
        return false unless other.instance_of?(self.class)
        path == other.path &&
          working_directory == other.working_directory
      end

      private

      def resolve_working_directory
        ::File.dirname(path)
      end

      def parse_contents
        begin
          contents = ::File.read(path)
        rescue ::StandardError => e
          @access_error = Error::InaccessibleInput.new(e.message)
          return
        end

        filename = ::File.basename(path)
        StringParser.call(contents, filename)
      end
    end
  end
end
