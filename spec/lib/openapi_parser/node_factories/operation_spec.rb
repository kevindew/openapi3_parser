# frozen_string_literal: true

require "openapi_parser/node_factories/operation"
require "openapi_parser/nodes/operation"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Operation do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Operation do
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
        ]
      }
    end

    let(:context) { create_context(input) }
  end
end
