# frozen_string_literal: true

require "openapi3_parser/node_factories/components"
require "openapi3_parser/node/components"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Components do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Components do
    let(:input) do
      {
        "schemas" => {
          "Category" => {
            "type" => "object",
            "properties" => {
              "id" => {
                "type" => "integer",
                "format" => "int64"
              },
              "name" => {
                "type" => "string"
              }
            }
          },
          "Tag" => {
            "type" => "object",
            "properties" => {
              "id" => {
                "type" => "integer",
                "format" => "int64"
              },
              "name" => {
                "type" => "string"
              }
            }
          },
          "GeneralError" => {
            "type" => "object",
            "properties" => {
              "description" => { "type" => "string" },
              "code" => { "type" => "integer" }
            }
          }
        },
        "parameters" => {
          "skipParam" => {
            "name" => "skip",
            "in" => "query",
            "description" => "number of items to skip",
            "required" => true,
            "schema" => {
              "type" => "integer",
              "format" => "int32"
            }
          },
          "limitParam" => {
            "name" => "limit",
            "in" => "query",
            "description" => "max records to return",
            "required" => true,
            "schema" => {
              "type" => "integer",
              "format" => "int32"
            }
          }
        },
        "responses" => {
          "NotFound" => {
            "description" => "Entity not found."
          },
          "IllegalInput" => {
            "description" => "Illegal input for operation."
          },
          "GeneralError" => {
            "description" => "General Error",
            "content" => {
              "application/json" => {
                "schema" => {
                  "$ref" => "#/components/schemas/GeneralError"
                }
              }
            }
          }
        },
        "securitySchemes" => {
          "api_key" => {
            "type" => "apiKey",
            "name" => "api_key",
            "in" => "header"
          },
          "petstore_auth" => {
            "type" => "oauth2",
            "flows" => {
              "implicit" => {
                "authorizationUrl" => "http://example.org/api/oauth/dialog",
                "scopes" => {
                  "write:pets" => "modify pets in your account",
                  "read:pets" => "read your pets"
                }
              }
            }
          }
        }
      }
    end

    let(:document_input) { { "components" => input } }

    let(:context) { create_context(input, document_input: document_input) }
  end
end
