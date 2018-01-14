# frozen_string_literal: true

require "open-uri"
require "openapi3_parser/source_input"
require "openapi3_parser/source_input/string_parser"
require "openapi3_parser/source_input/resolve_next"
require "openapi3_parser/error"

module Openapi3Parser
  class SourceInput
    # An input of a URL to an OpenAPI file
    #
    # @attr_reader [String] request_url   The URL that will be requested
    # @attr_reader [String] resolved_url  The eventual URL of the file that was
    #                                     accessed, this may differ to the
    #                                     request_url in the case of redirects
    class Url < SourceInput
      attr_reader :request_url, :resolved_url

      # @param [String, URI] request_url
      def initialize(request_url)
        @request_url = request_url.to_s
        initialize_contents
      end

      # @see SourceInput#resolve_next
      # @param  [Source::Reference] reference
      # @return [SourceInput]
      def resolve_next(reference)
        ResolveNext.call(reference, self, base_url: resolved_url)
      end

      # @see SourceInput#other
      # @param  [SourceInput] other
      # @return [Boolean]
      def ==(other)
        return false unless other.instance_of?(self.class)
        [request_url, resolved_url].include?(other.request_url) ||
          [request_url, resolved_url].include?(other.resolved_url)
      end

      private

      def parse_contents
        begin
          file = URI.parse(request_url).open
        rescue ::StandardError => e
          @access_error = Error::InaccessibleInput.new(e.message)
          return
        end
        @resolved_url = file.base_uri.to_s
        StringParser.call(file.read, resolved_url)
      end
    end
  end
end
