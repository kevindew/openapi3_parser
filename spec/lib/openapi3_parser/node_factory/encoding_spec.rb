# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Encoding do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Encoding do
    let(:input) do
      {
        "contentType" => "image/png, image/jpeg",
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current "\
                             "period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "default explode" do
    subject(:node) do
      described_class.new(node_factory_context).node(node_context)
    end

    let(:node_factory_context) do
      create_node_factory_context("style" => style)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end

    context "when style is 'form'" do
      let(:style) { "form" }
      it "has a value of true" do
        expect(node["explode"]).to be true
      end
    end

    context "when style is 'simple'" do
      let(:style) { "simple" }
      it "has a value of false" do
        expect(node["explode"]).to be false
      end
    end
  end
end
