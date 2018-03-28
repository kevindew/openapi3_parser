# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class DuplicateParameters
      def self.call(resolved_input)
        new.call(resolved_input)
      end

      def call(resolved_input)
        dupes = duplicate_names_by_in(resolved_input)
        message(dupes) unless dupes.empty?
      end

      private

      def duplicate_names_by_in(resolved_input)
        resolved_input.reject { |item| item["name"].nil? || item["in"].nil? }
                      .group_by { |item| [item["name"], item["in"]] }
                      .delete_if { |_, group| group.size < 2 }
                      .keys
      end

      def message(dupes)
        grouped = dupes.map { |d| "#{d.first} in #{d.last}" }.join(", ")
        "Duplicate parameters: #{grouped}"
      end
    end
  end
end
