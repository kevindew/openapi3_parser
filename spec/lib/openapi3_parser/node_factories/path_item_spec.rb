# frozen_string_literal: true

require "openapi3_parser/node_factories/path_item"
require "openapi3_parser/node/path_item"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::PathItem do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::PathItem do
    let(:input) do
      {
        "$ref" => "#/path_items/example",
        "get" => {
          "description" => "Returns pets based on ID",
          "summary" => "Find pets by ID",
          "operationId" => "getPetsById",
          "responses" => {
            "200" => {
              "description" => "pet response",
              "content" => {
                "*/*" => {
                  "schema" => {
                    "type" => "array",
                    "items" => { "type" => "string" }
                  }
                }
              }
            },
            "default" => {
              "description" => "error payload",
              "content" => {
                "text/html" => {
                  "schema" => { "type" => "string" }
                }
              }
            }
          }
        },
        "parameters" => [
          {
            "name" => "id",
            "in" => "path",
            "description" => "ID of pet to use",
            "required" => true,
            "schema" => {
              "type" => "array",
              "items" => {
                "type" => "string"
              }
            },
            "style" => "simple"
          }
        ]
      }
    end

    let(:document_input) do
      {
        "path_items" => {
          "example" => {
            "summary" => "Example"
          }
        }
      }
    end

    let(:context) { create_context(input, document_input: document_input) }
  end
end
