# frozen_string_literal: true

require "openapi3_parser/node_factories/paths"
require "openapi3_parser/nodes/paths"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Paths do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Nodes::Paths do
    let(:input) do
      {
        "/pets" => {
          "get" => {
            "description" => "Returns all pets that the user has access to",
            "responses" => {
              "200" => {
                "description" => "A list of pets.",
                "content" => {
                  "application/json" => {
                    "schema" => {
                      "type" => "array",
                      "items" => { "type" => "string" }
                    }
                  }
                }
              }
            }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
