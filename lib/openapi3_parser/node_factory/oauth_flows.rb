# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class OauthFlows < NodeFactory::Object
      allow_extensions
      field "implicit", factory: :oauth_flow_factory
      field "password", factory: :oauth_flow_factory
      field "clientCredentials", factory: :oauth_flow_factory
      field "authorizationCode", factory: :oauth_flow_factory

      def build_node(data, node_context)
        Node::OauthFlows.new(data, node_context)
      end

      private

      def oauth_flow_factory(context)
        NodeFactory::OptionalReference.new(NodeFactory::OauthFlow)
                                      .call(context)
      end
    end
  end
end
