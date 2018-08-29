# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class OauthFlow < NodeFactory::Object
      allow_extensions
      field "authorizationUrl", input_type: String
      field "tokenUrl", input_type: String
      field "refreshUrl", input_type: String
      field "scopes", input_type: Hash

      private

      def build_object(data, context)
        Node::OauthFlow.new(data, context)
      end
    end
  end
end
