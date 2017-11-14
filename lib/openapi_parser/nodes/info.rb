# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/contact"
require "openapi_parser/nodes/license"

module OpenapiParser
  module Nodes
    class Info
      attr_reader :data, :context

      def initialize(data, context)
        @data = data
        @context = context
      end

      def title
        data["title"]
      end

      def description
        data["description"]
      end

      def terms_of_service
        data["termsOfService"]
      end

      def contact
        data["contact"]
      end

      def license
        data["license"]
      end

      def version
        data["version"]
      end
    end
  end
end
