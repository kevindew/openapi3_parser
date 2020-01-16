# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Example do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Example do
    let(:input) do
      {
        "summary" => "Summary",
        "value" => [1, 2, 3],
        "x-otherField" => "Extension value"
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "externalValue" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:node_factory_context) do
      create_node_factory_context({ "externalValue" => external_value })
    end

    context "when externalValue is an actual url" do
      let(:external_value) { "https://example.com/path" }
      it { is_expected.to be_valid }
    end

    context "when externalValue is not a url" do
      let(:external_value) { "not a url" }
      it { is_expected.not_to be_valid }
    end
  end

  describe "mutually exclusive value externalValue" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "value" => value,
                                    "externalValue" => external_value })
    end
    let(:value) { nil }
    let(:external_value) { nil }

    context "when neither value or externalValue is provided" do
      it { is_expected.to be_valid }
    end

    context "when a value is provided" do
      let(:value) { "anything" }
      it { is_expected.to be_valid }
    end

    context "when examples are provided" do
      let(:external_value) { "/" }
      it { is_expected.to be_valid }
    end

    context "when both are provided" do
      let(:value) { "anything" }
      let(:external_value) { "/" }
      it do
        is_expected
          .to have_validation_error("#/")
          .with_message(
            "value and externalValue are mutually exclusive fields"
          )
      end
    end
  end
end
