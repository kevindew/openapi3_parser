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

      private

      def oauth_flow_factory(context)
        NodeFactory::OptionalReference.new(NodeFactory::OauthFlow)
                                      .call(context)
      end

      def build_object(data, context)
        Node::OauthFlows.new(data, context)
      end
    end
  end
end
