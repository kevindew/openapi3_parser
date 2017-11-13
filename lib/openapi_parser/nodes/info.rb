# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/nodes/contact"
require "openapi_parser/nodes/license"

module OpenapiParser
  module Nodes
    class Info
      include Node

      allow_extensions

      field "title", input_type: String, required: true
      field "description", input_type: String
      field "termsOfService", input_type: String
      field "contact", input_type: Hash, build: ->(i, c) { Contact.new(i, c) }
      field "license", input_type: Hash, build: ->(i, c) { License.new(i, c) }
      field "version", input_type: String, required: true

      def title
        fields["title"]
      end

      def description
        fields["description"]
      end

      def terms_of_service
        fields["termsOfService"]
      end

      def contact
        fields["contact"]
      end

      def license
        fields["license"]
      end

      def version
        fields["version"]
      end
    end
  end
end
