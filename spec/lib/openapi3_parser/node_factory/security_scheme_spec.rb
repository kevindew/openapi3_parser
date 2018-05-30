# frozen_string_literal: true

require "openapi3_parser/node_factory/security_scheme"
require "openapi3_parser/node/security_scheme"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::SecurityScheme do
  include Helpers::Context

  it_behaves_like "node object factory",
                  Openapi3Parser::Node::SecurityScheme do
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

    let(:context) { create_context(input) }
  end
end
