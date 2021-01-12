# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Discriminator do
  it_behaves_like "node object factory", Openapi3Parser::Node::Discriminator do
    let(:input) do
      {
        "propertyName" => "test",
        "mapping" => { "key" => "value" }
      }
    end
  end
end
