# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Operation do
  it_behaves_like "node object factory", Openapi3Parser::Node::Operation do
    let(:input) do
      {
        "tags" => %w[pet],
        "summary" => "Updates a pet in the store with form data",
        "operationId" => "updatePetWithForm",
        "parameters" => [
          {
            "name" => "petId",
            "in" => "path",
            "description" => "ID of pet that needs to be updated",
            "required" => true,
            "schema" => { "type" => "string" }
          }
        ],
        "requestBody" => {
          "content" => {
            "application/x-www-form-urlencoded" => {
              "schema" => {
                "type" => "object",
                "properties" => {
                  "name" => {
                    "description" => "Updated name of the pet",
                    "type" => "string"
                  },
                  "status" => {
                    "description" => "Updated status of the pet",
                    "type" => "string"
                  }
                },
                "required" => %w[status]
              }
            }
          }
        },
        "responses" => {
          "200" => {
            "description" => "Pet updated.",
            "content" => {
              "application/json" => {},
              "application/xml" => {}
            }
          },
          "405" => {
            "description" => "Invalid input",
            "content" => {
              "application/json" => {},
              "application/xml" => {}
            }
          }
        },
        "callbacks" => {
          "myWebhook" => {
            "http://notificationServer.com?transactionId={$request.body#/id}" \
            "&email={$request.body#/email}" => {
              "post" => {
                "requestBody" => {
                  "description" => "Callback payload",
                  "content" => {
                    "application/json" => {
                      "schema" => { "type" => "string" }
                    }
                  }
                },
                "responses" => {
                  "200" => {
                    "description" => "webhook successfully processed"
                  }
                }
              }
            }
          }
        },
        "security" => [
          {
            "petstore_auth" => [
              "write:pets",
              "read:pets"
            ]
          }
        ],
        "servers" => [
          {
            "url" => "https://development.gigantic-server.com/v1",
            "description" => "Development server"
          }
        ]
      }
    end
  end

  describe "validating parameters" do
    it "is valid when parameters are valid" do
      factory_context = create_node_factory_context(
        {
          "parameters" => [
            { "name" => "id", "in" => "header" },
            { "name" => "id", "in" => "query" }
          ],
          "responses" => {}
        }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when there are duplicate parameters" do
      factory_context = create_node_factory_context(
        {
          "parameters" => [
            { "name" => "id", "in" => "query" },
            { "name" => "id", "in" => "query" }
          ],
          "responses" => {}
        }
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/parameters")
    end

    it "is invalid when parameters are the wrong type" do
      factory_context = create_node_factory_context(
        {
          "parameters" => [1, "string"],
          "responses" => {}
        }
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/parameters/0")
        .and have_validation_error("#/parameters/1")
    end
  end

  describe "servers" do
    let(:input) do
      {
        "responses" => {},
        "servers" => servers
      }
    end

    let(:document_input) do
      {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Minimal Openapi definition",
          "version" => "1.0.0"
        },
        "paths" => {
          "/test" => {
            "get" => input,
            "servers" => [
              {
                "url" => "https://dev.example.com/v1",
                "description" => "Development server"
              }
            ]
          }
        }
      }
    end

    let(:node) do
      node_factory_context = create_node_factory_context(
        input,
        document_input: document_input,
        pointer_segments: %w[paths /test get]
      )
      node_context = node_factory_context_to_node_context(node_factory_context)
      described_class.new(node_factory_context)
                     .node(node_context)
    end

    shared_examples "defaults to servers from path item object" do
      it "uses the servers from the path item object" do
        expect(node["servers"][0].url).to eq "https://dev.example.com/v1"
        expect(node["servers"][0].description).to eq "Development server"
      end
    end

    context "when servers is nil" do
      let(:servers) { nil }

      include_examples "defaults to servers from path item object"
    end

    context "when servers is an empty array" do
      let(:servers) { [] }

      include_examples "defaults to servers from path item object"
    end

    context "when servers are provided" do
      let(:servers) do
        [
          {
            "url" => "https://prod.example.com/v1",
            "description" => "Production server"
          }
        ]
      end

      it "uses it's defined servers" do
        expect(node["servers"][0].url).to eq "https://prod.example.com/v1"
        expect(node["servers"][0].description).to eq "Production server"
      end
    end
  end

  describe "responses field" do
    it "requires this field for OpenAPI 3.0" do
      context = create_node_factory_context({}, document_input: { "openapi" => "3.0.0" })
      instance = described_class.new(context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("Missing required fields: responses")
    end

    it "doesn't require this field for OpenAPI > 3.0" do
      context = create_node_factory_context({}, document_input: { "openapi" => "3.1.0" })
      expect(described_class.new(context)).to be_valid
    end
  end
end
