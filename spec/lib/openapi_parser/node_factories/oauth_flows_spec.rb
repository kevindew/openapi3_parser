# frozen_string_literal: true

require "openapi_parser/node_factories/oauth_flows"
require "openapi_parser/nodes/oauth_flows"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::OauthFlows do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::OauthFlows do
    let(:input) do
      {
        "authorizationCode" => {
          "$ref" => "#/myReference"
        }
      }
    end

    let(:document_input) do
      {
        "myReference" => {
          "authorizationUrl" => "https://example.com/api/oauth/dialog",
          "tokenUrl" => "https://example.com/api/oauth/token",
          "scopes" => {
            "write:pets" => "modify pets in your account",
            "read:pets" => "read your pets"
          }
        }
      }
    end

    let(:context) { create_context(input, document_input: document_input) }
  end
end
