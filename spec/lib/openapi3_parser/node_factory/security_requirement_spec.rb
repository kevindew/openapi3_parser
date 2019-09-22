# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::SecurityRequirement do
  include Helpers::Context

  it_behaves_like "node object factory",
                  Openapi3Parser::Node::SecurityRequirement do
    let(:input) do
      {
        "petstore_auth" => %w[write:pets read:pets]
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end
end
