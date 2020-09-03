# frozen_string_literal: true

require "openapi3_parser/source_input"

module Openapi3Parser
  class SourceInput
    # An input of data (typically a Hash) to for initialising an OpenAPI
    # document. Most likely used in development scenarios when you want to
    # test things without creating/tweaking an OpenAPI source file
    #
    # @attr_reader [Object]       raw_input         The data for the document
    # @attr_reader [String, nil]  base_url          A url to be used for
    #                                               resolving relative
    #                                               references
    # @attr_reader [String, nil]  working_directory A path to be used for
    #                                               resolving relative
    #                                               references
    class Raw < SourceInput
      attr_reader :raw_input, :base_url, :working_directory

      # @param [Object]       raw_input
      # @param [String, nil]  base_url
      # @param [String, nil]  working_directory
      def initialize(raw_input, base_url: nil, working_directory: nil)
        @raw_input = raw_input
        @base_url = base_url
        working_directory ||= resolve_working_directory
        @working_directory = ::File.absolute_path(working_directory)
        super()
      end

      # @see SourceInput#resolve_next
      # @param  [Source::Reference] reference
      # @return [SourceInput]
      def resolve_next(reference)
        ResolveNext.call(reference,
                         self,
                         base_url: base_url,
                         working_directory: working_directory)
      end

      # @see SourceInput#other
      # @param  [SourceInput] other
      # @return [Boolean]
      def ==(other)
        return false unless other.instance_of?(self.class)

        raw_input == other.raw_input &&
          base_url == other.base_url &&
          working_directory == other.working_directory
      end

      # return [String]
      def inspect
        %{#{self.class.name}(input: #{raw_input.inspect}, base_url: } +
          %{#{base_url}, working_directory: #{working_directory})}
      end

      # @return [String]
      def to_s
        raw_input.to_s
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
