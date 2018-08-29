# frozen_string_literal: true

require "cgi"

module Openapi3Parser
  class Source
    # An object which represents a reference that can be indicated in a OpenAPI
    # file. Given a string reference it can be used to answer key questions
    # that aid in resolving the reference
    #
    # e.g.
    # r = Openapi3Parser::Source::Reference.new("test.yaml#/path/to/item")
    #
    # r.only_fragment?
    # => false
    #
    # r.rsource_uri
    # => "test.yaml"
    class Reference
      # @param [String] reference   reference from an OpenAPI file
      def initialize(reference)
        @given_reference = reference
      end

      def to_s
        given_reference.to_s
      end

      def only_fragment?
        resource_uri.to_s == ""
      end

      # @return [String, nil]
      def fragment
        uri.fragment
      end

      # @return [URI]
      def resource_uri
        uri_without_fragment
      end

      def absolute?
        uri.absolute?
      end

      # @return [::Array] an array of strings of the components in the fragment
      def json_pointer
        @json_pointer ||= (fragment || "").split("/").drop(1).map do |field|
          CGI.unescape(field.gsub("+", "%20"))
        end
      end

      private

      attr_reader :given_reference

      def uri
        @uri = URI.parse(given_reference)
      end

      def uri_without_fragment
        @uri_without_fragment ||= uri.dup.tap { |u| u.fragment = nil }
      end
    end
  end
end
