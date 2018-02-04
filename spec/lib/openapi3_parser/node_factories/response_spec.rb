# frozen_string_literal: true

require "openapi3_parser/node_factories/response"
require "openapi3_parser/node/response"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Response do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Response do
    let(:input) do
      {
        "description" => "A simple string response",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "string"
            }
          }
        },
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Remaining" => {
            "description" => "The number of remaining requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Reset" => {
            "description" => "The number of seconds left in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
