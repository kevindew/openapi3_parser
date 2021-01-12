# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::SecurityRequirement do
  it_behaves_like "node object factory", Openapi3Parser::Node::SecurityRequirement do
    let(:input) do
      {
        "petstore_auth" => %w[write:pets read:pets]
      }
    end
  end
end
