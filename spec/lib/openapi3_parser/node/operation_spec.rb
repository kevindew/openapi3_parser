# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::Operation do
  include Helpers::Context

  describe "#alternative_servers?" do
    subject { instance.alternative_servers? }

    let(:instance) do
      input = {
        "responses" => {},
        "servers" => servers
      }

      factory_context = create_node_factory_context(
        input,
        document_input: {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "paths" => { "/test" => { "get" => input } }
        },
        pointer_segments: %w[paths /test get]
      )

      Openapi3Parser::NodeFactory::Operation
        .new(factory_context)
        .node(node_factory_context_to_node_context(factory_context))
    end

    context "when object has alternative servers defined" do
      let(:servers) { [{ "url" => "https://example.com" }] }

      it { is_expected.to be true }
    end

    context "when object uses cascading servers" do
      let(:servers) { nil }

      it { is_expected.to be false }
    end
  end
end
