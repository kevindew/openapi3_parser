# frozen_string_literal: true

module OpenapiParser
  class Node
    class Info
      attr_reader :attributes, :extensions

      def initialize(input)
        @input = input
        @attributes = build_nodes(input.dup)
        @extensions = extract_extensions(@attributes)
      end

      def [](value)
        attributes[value]
      end

      def title
        attributes["title"]
      end

      def description
        attributes["description"]
      end

      def terms_of_service
        attributes["termsOfService"]
      end

      def contact
        attributes["contact"]
      end

      def license
        attributes["license"]
      end

      def version
        attributes["version"]
      end

      def extension(value)
        extensions[value]
      end

      private

      def build_nodes(input)
        input.each_with_object({}) do |(key, value), memo|
          memo[key] = value
        end
      end

      def extract_extensions(attributes)
        attributes.each_with_object({}) do |(key, value), memo|
          memo[Regexp.last_match(1)] = value if key =~ /^x-(.*)/
        end
      end
    end
  end
end
