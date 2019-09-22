# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::NodeBuilder do
  include Helpers::Context

  describe ".errors" do
    let(:input) { nil }
    let(:factory) do
      Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context(input)
      )
    end

    subject { described_class.errors(factory) }

    it { is_expected.to be_a(Openapi3Parser::Validation::ErrorCollection) }

    context "when given a nil input and factory allows a default" do
      let(:input) { nil }
      before do
        allow(factory).to receive(:can_use_default?).and_return(true)
      end

      it { is_expected.to be_empty }
    end

    context "when given a nil input and factory doesn't allow a default" do
      let(:input) { nil }
      before do
        allow(factory).to receive(:can_use_default?).and_return(false)
      end

      it { is_expected.not_to be_empty }
    end

    context "when object has data and is valid" do
      let(:input) { { "email" => "valid-email@example.com" } }

      it { is_expected.to be_empty }
    end

    context "when object has data and is invalid" do
      let(:input) { { "email" => "invalid email" } }

      it { is_expected.not_to be_empty }
    end
  end

  describe ".node_data" do
    let(:input) { nil }
    let(:node_factory_context) { create_node_factory_context(input) }

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end

    let(:factory) do
      Openapi3Parser::NodeFactory::Contact.new(node_factory_context)
    end

    subject(:node_data) { described_class.node_data(factory, node_context) }

    context "when given a nil input and factory allows that" do
      let(:input) { nil }
      before do
        allow(factory).to receive(:can_use_default?).and_return(true)
      end

      it { is_expected.to be nil }
    end

    context "when given a nil input and factory doesn't allow a default" do
      let(:input) { nil }
      before do
        allow(factory).to receive(:can_use_default?).and_return(false)
      end

      it "raises an error" do
        expect { node_data }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end

    context "when object has data and is valid" do
      let(:input) { { "email" => "valid-email@example.com" } }

      it { is_expected.to be_a(Hash) }
    end

    context "when object has data and is invalid" do
      let(:input) { { "email" => "invalid email" } }

      it "raises an error" do
        expect { node_data }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end
end
