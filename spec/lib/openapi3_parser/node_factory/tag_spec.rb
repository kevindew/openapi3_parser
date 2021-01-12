# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Tag do
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
  end
end
