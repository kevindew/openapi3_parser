# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#infoObject
    class Info < Node::Object
      # @return [String]
      def title
        self["title"]
      end

      # @return [String, nil]
      def description
        self["description"]
      end

      # @return [String, nil]
      def description_html
        render_markdown(description)
      end

      # @return [String, nil]
      def terms_of_service
        self["termsOfService"]
      end

      # @return [Contact, nil]
      def contact
        self["contact"]
      end

      # @return [License, nil]
      def license
        self["license"]
      end

      # @return [String]
      def version
        self["version"]
      end
    end
  end
end
