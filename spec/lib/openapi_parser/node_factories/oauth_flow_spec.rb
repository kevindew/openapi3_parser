# frozen_string_literal: true

require "openapi_parser/node_factories/oauth_flow"
require "openapi_parser/nodes/oauth_flow"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::OauthFlow do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::OauthFlow do
    let(:input) do
      {
        "authorizationUrl" => "https://example.com/api/oauth/dialog",
        "tokenUrl" => "https://example.com/api/oauth/token",
        "scopes" => {
          "write:pets" => "modify pets in your account",
          "read:pets" => "read your pets"
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
