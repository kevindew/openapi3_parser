# frozen_string_literal: true

require "openapi_parser/node_factories/discriminator"
require "openapi_parser/nodes/discriminator"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Discriminator do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Discriminator do
    let(:input) do
      {
        "propertyName" => "test",
        "mapping" => { "key" => "value" }
      }
    end

    let(:context) { create_context(input) }
  end
end
