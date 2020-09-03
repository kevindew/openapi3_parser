# frozen_string_literal: true

require "openapi3_parser/source_input"

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
      def initialize(path, working_directory: nil)
        @path = ::File.absolute_path(path)
        working_directory ||= resolve_working_directory
        @working_directory = ::File.absolute_path(working_directory)
        super()
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

      # return [String]
      def inspect
        %{#{self.class.name}(path: #{path}, working_directory: } +
          %{#{working_directory})}
      end

      # @return [String]
      def to_s
        path
      end

      # Attempt to return a shorter relative path to the other source input
      # so we can produce succinct output
      #
      # @return [String]
      def relative_to(source_input)
        other_path = if source_input.respond_to?(:path)
                       ::File.dirname(source_input.path)
                     elsif source_input.respond_to?(:working_directory)
                       source_input.working_directory
                     end

        return path unless other_path

        other_path ? relative_path(other_path, path) : path
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

      def relative_path(from, to)
        from_path = Pathname.new(from)
        to_path = Pathname.new(to)
        relative = to_path.relative_path_from(from_path).to_s

        relative.size > to.size ? to : relative
      end
    end
  end
end
