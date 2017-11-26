# frozen_string_literal: true

require "openapi3_parser/node_factories/link"
require "openapi3_parser/nodes/link"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Link do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Nodes::Link do
    let(:input) do
      {
        "operationRef" => "#/paths/~12.0~1repositories~1{username}/get",
        "parameters" => { "username" => "$response.body#/username" }
      }
    end

    let(:context) { create_context(input) }
  end
end
