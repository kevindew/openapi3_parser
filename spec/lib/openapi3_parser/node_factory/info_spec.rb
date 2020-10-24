# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Info do
  include Helpers::Context
  let(:minimal_info_definition) do
    {
      "title" => "Info",
      "version" => "1.0"
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Info do
    let(:input) do
      minimal_info_definition.merge(
        "license" => { "name" => "License" },
        "contact" => { "name" => "Contact" }
      )
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "terms of service" do
    subject(:factory) { described_class.new(node_factory_context) }

    let(:input) do
      minimal_info_definition.merge("termsOfService" => terms_of_service)
    end
    let(:node_factory_context) { create_node_factory_context(input) }

    context "when terms of service is a url" do
      let(:terms_of_service) { "https://example.com/path" }

      it { is_expected.to be_valid }
    end

    context "when terms of service is not a url" do
      let(:terms_of_service) { "not a url" }

      it { is_expected.not_to be_valid }
    end
  end
end
