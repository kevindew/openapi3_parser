# frozen_string_literal: true

require "openapi_parser/node_factories/request_body"
require "openapi_parser/nodes/request_body"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::RequestBody do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::RequestBody do
    let(:input) do
      {
        "description" => "user to add to the system",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "array",
              "items" => { "type" => "string" }
            }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
