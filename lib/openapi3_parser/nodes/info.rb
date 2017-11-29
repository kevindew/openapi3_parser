# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#infoObject
    class Info
      include Node::Object

      # @return [String]
      def title
        node_data["title"]
      end

      # @return [String, null]
      def description
        node_data["description"]
      end

      # @return [String, null]
      def terms_of_service
        node_data["termsOfService"]
      end

      # @return [Contact, nil]
      def contact
        node_data["contact"]
      end

      # @return [License, nil]
      def license
        node_data["license"]
      end

      # @return [String]
      def version
        node_data["version"]
      end
    end
  end
end
