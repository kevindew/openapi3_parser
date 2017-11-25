# frozen_string_literal: true

require "openapi_parser/node_factories/responses"
require "openapi_parser/nodes/responses"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Responses do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Responses do
    let(:input) do
      {
        "200" => {
          "description" => "a pet to be returned",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        },
        "default" => {
          "description" => "Unexpected error",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
