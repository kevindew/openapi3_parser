# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::PathItem do
  include Helpers::Context

  describe "#alternative_servers?" do
    let(:instance) do
      factory_context = create_node_factory_context(
        input,
        document_input: {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "paths" => {}
        }
      )

      Openapi3Parser::NodeFactory::PathItem
        .new(factory_context)
        .node(node_factory_context_to_node_context(factory_context))
    end

    subject { instance.alternative_servers? }

    context "when object has alternative servers defined" do
      let(:input) do
        {
          "servers" => [{ "url" => "https://example.com" }]
        }
      end

      it { is_expected.to be true }
    end

    context "when object uses the root servers" do
      let(:input) { {} }

      it { is_expected.to be false }
    end
  end
end
