# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::OauthFlows do
  it_behaves_like "node object factory", Openapi3Parser::Node::OauthFlows do
    let(:input) do
      {
        "authorizationCode" => {
          "$ref" => "#/myReference"
        }
      }
    end

    let(:document_input) do
      {
        "openapi" => "3.0.0",
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

    let(:node_factory_context) do
      create_node_factory_context(input, document_input:)
    end
  end
end
