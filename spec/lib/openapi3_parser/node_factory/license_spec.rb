# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::License do
  include Helpers::Context

  let(:minimal_license_definition) { { "name" => "License" } }

  it_behaves_like "node object factory", Openapi3Parser::Node::License do
    let(:input) { minimal_license_definition }
    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "url" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:node_factory_context) do
      create_node_factory_context(
        minimal_license_definition.merge("url" => url)
      )
    end

    context "when url is an actual url" do
      let(:url) { "https://example.com/path" }
      it { is_expected.to be_valid }
    end

    context "when url is not a url" do
      let(:url) { "not a url" }
      it { is_expected.not_to be_valid }
    end
  end
end
