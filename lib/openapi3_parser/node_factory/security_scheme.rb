# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class SecurityScheme < NodeFactory::Object
      allow_extensions

      field "type", input_type: String, required: true
      field "description", input_type: String
      field "name", input_type: String
      field "in", input_type: String
      field "scheme", input_type: String
      field "bearerFormat", input_type: String
      field "flows", factory: :flows_factory
      field "openIdConnectUrl", input_type: String

      private

      def build_object(data, context)
        Node::SecurityScheme.new(data, context)
      end

      def flows_factory(context)
        NodeFactory::OauthFlows.new(context)
      end
    end
  end
end
