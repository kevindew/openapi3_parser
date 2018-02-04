# frozen_string_literal: true

require "openapi3_parser/node_factories/responses"
require "openapi3_parser/node/responses"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Responses do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Responses do
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
