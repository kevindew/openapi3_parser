# frozen_string_literal: true

module Openapi3Parser
  class SourceInput
    class ResolveNext
      # @param  reference            [Source::Reference]
      # @param  current_source_input [SourceInput]
      # @param  base_url             [String, nil]
      # @param  working_directory    [String, nil]
      # @return [SourceInput]
      def self.call(reference,
                    current_source_input,
                    base_url: nil,
                    working_directory: nil)
        new(reference, current_source_input, base_url, working_directory)
          .source_input
      end

      def initialize(reference,
                     current_source_input,
                     base_url,
                     working_directory)
        @reference = reference
        @current_source_input = current_source_input
        @base_url = base_url
        @working_directory = working_directory
      end

      private_class_method :new

      def source_input
        return current_source_input if reference.only_fragment?

        if reference.absolute?
          SourceInput::Url.new(reference.resource_uri)
        else
          base_url ? url_source_input : file_source_input
        end
      end

      private

      attr_reader :reference, :current_source_input, :base_url,
                  :working_directory

      def url_source_input
        url = URI.join(base_url, reference.resource_uri)
        SourceInput::Url.new(url)
      end

      def file_source_input
        path = reference.resource_uri.path
        return SourceInput::File.new(path) if path[0] == "/"

        expanded_path = ::File.expand_path(path, working_directory)
        SourceInput::File.new(expanded_path)
      end
    end
  end
end
