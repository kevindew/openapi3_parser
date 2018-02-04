# frozen_string_literal: true

require "openapi3_parser/node_factories/tag"
require "openapi3_parser/node/tag"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Tag do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Tag do
    let(:input) do
      {
        "name" => "pet",
        "description" => "Pets operations",
        "externalDocs" => {
          "description" => "Find more info here",
          "url" => "https://example.com"
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
