# frozen_string_literal: true

require "psych"
require "json"

module Openapi3Parser
  class SourceInput
    class StringParser
      def self.call(input, filename = nil)
        new(input, filename).call
      end

      def initialize(input, filename)
        @input = input
        @filename = filename
      end

      def call
        json? ? parse_json : parse_yaml
      end

      private_class_method :new

      private

      attr_reader :input, :filename

      def json?
        return false if filename && ::File.extname(filename) == ".yaml"

        json_filename = filename && ::File.extname(filename) == ".json"
        json_filename || input.strip[0] == "{"
      end

      def parse_json
        JSON.parse(input)
      end

      def parse_yaml
        Psych.safe_load(input, permitted_classes: [Date, Time], aliases: true)
      end
    end
  end
end
