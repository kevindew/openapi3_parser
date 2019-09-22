# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Header do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Header do
    let(:input) do
      {
        "description" => "token to be passed as a header",
        "required" => true,
        "schema" => {
          "type" => "array",
          "items" => {
            "type" => "integer",
            "format" => "int64"
          }
        },
        "style" => "simple",
        "x-additional" => "test"
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end
end
