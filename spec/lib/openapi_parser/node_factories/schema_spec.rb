# frozen_string_literal: true

require "openapi_parser/node_factories/schema"
require "openapi_parser/nodes/schema"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Schema do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Schema do
    let(:input) do
      {
        "type" => "object",
        "required" => %w[message code],
        "properties" => {
          "message" => {
            "type" => "string"
          },
          "code" => {
            "type" => "integer",
            "minimum" => 100,
            "maximum" => 600
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
