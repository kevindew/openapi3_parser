# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Operation do
  include Helpers::Context

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
            "http://notificationServer.com?transactionId={$request.body#/id}"\
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

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "parameters" do
    subject do
      described_class.new(
        create_node_factory_context(
          "parameters" => parameters,
          "responses" => {}
        )
      )
    end

    context "when there are no duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "header" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.to be_valid }
    end

    context "when there are duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "query" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.not_to be_valid }
    end

    context "when parameters are in the wrong type" do
      let(:parameters) { [1, "string"] }

      it { is_expected.not_to be_valid }
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

    let(:node_factory_context) do
      create_node_factory_context(input,
                                  document_input: document_input,
                                  pointer_segments: %w[paths /test get])
    end

    let(:instance) { described_class.new(node_factory_context) }

    let(:node) do
      node_context = node_factory_context_to_node_context(node_factory_context)
      instance.node(node_context)
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
end
