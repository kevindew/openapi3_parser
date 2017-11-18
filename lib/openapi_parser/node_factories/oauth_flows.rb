# frozen_string_literal: true

require "openapi_parser/nodes/oauth_flows"
require "openapi_parser/node_factories/oauth_flow"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/optional_reference"

module OpenapiParser
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
        Nodes::OauthFlows.new(data, context)
      end
    end
  end
end
