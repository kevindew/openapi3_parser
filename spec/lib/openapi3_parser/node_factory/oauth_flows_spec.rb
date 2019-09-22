# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::OauthFlows do
  include Helpers::Context

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
      create_node_factory_context(input, document_input: document_input)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end
end
