# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Nodes
    class Info
      include Node::Object

      def title
        node_data["title"]
      end

      def description
        node_data["description"]
      end

      def terms_of_service
        node_data["termsOfService"]
      end

      def contact
        node_data["contact"]
      end

      def license
        node_data["license"]
      end

      def version
        node_data["version"]
      end
    end
  end
end
