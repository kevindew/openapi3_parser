# frozen_string_literal: true

require "openapi3_parser/node_factories/example"
require "openapi3_parser/node/example"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Example do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Example do
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
