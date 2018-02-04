# frozen_string_literal: true

require "openapi3_parser/node_factories/discriminator"
require "openapi3_parser/node/discriminator"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Discriminator do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Discriminator do
    let(:input) do
      {
        "propertyName" => "test",
        "mapping" => { "key" => "value" }
      }
    end

    let(:context) { create_context(input) }
  end
end
