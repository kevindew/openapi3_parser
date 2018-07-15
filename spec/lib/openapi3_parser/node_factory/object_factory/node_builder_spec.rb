# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/node_factory/contact"
require "openapi3_parser/node_factory/object_factory/node_builder"
require "openapi3_parser/validation/error_collection"

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::NodeBuilder do
  include Helpers::Context

  describe ".errors" do
    let(:input) { nil }
    let(:factory) do
      Openapi3Parser::NodeFactory::Contact.new(create_context(input))
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
    let(:factory) do
      Openapi3Parser::NodeFactory::Contact.new(create_context(input))
    end

    subject(:node_data) { described_class.node_data(factory) }

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
