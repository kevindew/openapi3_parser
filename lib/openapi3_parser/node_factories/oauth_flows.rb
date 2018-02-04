# frozen_string_literal: true

require "openapi3_parser/node/oauth_flows"
require "openapi3_parser/node_factories/oauth_flow"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/optional_reference"

module Openapi3Parser
  module NodeFactories
    class OauthFlows
      include NodeFactory::Object

      allow_extensions
      field "implicit", factory: :oauth_flow_factory
      field "password", factory: :oauth_flow_factory
      field "clientCredentials", factory: :oauth_flow_factory
      field "authorizationCode", factory: :oauth_flow_factory

      private

      def oauth_flow_factory(context)
        NodeFactory::OptionalReference.new(NodeFactories::OauthFlow)
                                      .call(context)
      end

      def build_object(data, context)
        Node::OauthFlows.new(data, context)
      end
    end
  end
end
