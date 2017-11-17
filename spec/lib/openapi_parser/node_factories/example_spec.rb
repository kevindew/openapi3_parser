# frozen_string_literal: true

require "openapi_parser/node_factories/example"
require "openapi_parser/nodes/example"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Example do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Example do
    let(:input) do
      {
        "summary" => "Summary",
        "value" => [1, 2, 3],
        "x-otherField" => "Extension value"
      }
    end

    let(:context) { create_context(input) }
  end
end
