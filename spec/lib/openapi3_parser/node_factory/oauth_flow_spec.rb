# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::OauthFlow do
  it_behaves_like "node object factory", Openapi3Parser::Node::OauthFlow do
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
  end
end
