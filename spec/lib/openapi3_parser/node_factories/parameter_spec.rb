# frozen_string_literal: true

require "openapi3_parser/node_factories/parameter"
require "openapi3_parser/nodes/parameter"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Parameter do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Nodes::Parameter do
    let(:input) do
      {
        "name" => "id",
        "in" => "query",
        "description" => "ID of the object to fetch",
        "required" => false,
        "schema" => {
          "type" => "array",
          "items" => {
            "type" => "string"
          }
        },
        "style" => "form",
        "explode" => true
      }
    end

    let(:context) { create_context(input) }
  end
end
