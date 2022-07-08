# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Components do
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

    let(:node_factory_context) do
      create_node_factory_context(input,
                                  document_input: { "components" => input })
    end
  end

  describe "validing response key format" do
    it "is valid for a valid key" do
      factory_context = create_node_factory_context(
        {
          "responses" => {
            "valid.key" => { "description" => "Example description" }
          }
        }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an invalid key" do
      factory_context = create_node_factory_context(
        {
          "responses" => {
            "Invalid Key" => { "description" => "Example description" }
          }
        }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/responses")
    end
  end

  describe "pathItems field" do
    it "accepts this field for OpenAPI >= 3.1" do
      factory_context = create_node_factory_context(
        {
          "pathItems" => { "key" => { "summary" => "Item summary" } }
        },
        document_input: { "openapi" => "3.1.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).to be_valid
    end

    it "rejects this field for OpenAPI < 3.1" do
      factory_context = create_node_factory_context(
        {
          "pathItems" => { "key" => { "summary" => "Item summary" } }
        },
        document_input: { "openapi" => "3.0.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
    end
  end
end
