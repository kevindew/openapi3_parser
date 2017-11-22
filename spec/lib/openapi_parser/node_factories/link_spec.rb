# frozen_string_literal: true

require "openapi_parser/node_factories/link"
require "openapi_parser/nodes/link"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Link do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Link do
    let(:input) do
      {
        "operationRef" => "#/paths/~12.0~1repositories~1{username}/get",
        "parameters" => { "username" => "$response.body#/username" }
      }
    end

    let(:context) { create_context(input) }
  end
end
