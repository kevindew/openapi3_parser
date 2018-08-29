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

    let(:context) { create_context(input) }
  end
end
