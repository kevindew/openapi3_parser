# frozen_string_literal: true

require "openapi_parser/node_factories/path_item"
require "openapi_parser/nodes/path_item"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::PathItem do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::PathItem do
    let(:input) do
      {
        "$ref" => "#/path_items/example",
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
