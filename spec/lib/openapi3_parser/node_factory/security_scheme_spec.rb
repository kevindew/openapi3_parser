# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::SecurityScheme do
  it_behaves_like "node object factory", Openapi3Parser::Node::SecurityScheme do
    let(:input) do
      {
        "type" => "oauth2",
        "flows" => {
          "implicit" => {
            "authorizationUrl" => "https://example.com/api/oauth/dialog",
            "scopes" => {
              "write =>pets": "modify pets in your account",
              "read =>pets": "read your pets"
            }
          }
        }
      }
    end
  end
end
