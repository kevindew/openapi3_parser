# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Fields::Reference do
  include Helpers::Context

  let(:factory_class) { Openapi3Parser::NodeFactory::Contact }
  let(:factory_context) do
    create_node_factory_context(
      "#/reference",
      document_input: document_input,
      pointer_segments: %w[field $ref]
    )
  end

  describe "#resolved_input" do
    subject do
      described_class.new(factory_context, factory_class).resolved_input
    end

    context "when reference can be resolved" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it { is_expected.to match(hash_including("name" => "Joe")) }
    end

    context "when reference can't be resolved" do
      let(:document_input) do
        { "not_reference" => {} }
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#node" do
    subject(:node) do
      described_class.new(factory_context, factory_class).node(node_context)
    end

    let(:node_context) do
      node_factory_context_to_node_context(factory_context)
    end

    context "when reference is valid" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it { is_expected.to be_a(Openapi3Parser::Node::Contact) }
    end

    context "when reference is invalid" do
      let(:document_input) do
        { "reference" => { "url" => "invalid url" } }
      end

      it "raises an error" do
        expect { node }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end

  describe "validations" do
    let(:instance) { described_class.new(factory_context, factory_class) }

    context "when reference is valid" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it "is valid" do
        expect(instance).to be_valid
      end

      it "has no errors" do
        expect(instance.errors).to be_empty
      end
    end

    context "when reference is invalid" do
      let(:document_input) do
        { "reference" => { "url" => "invalid url" } }
      end

      it "is invalid" do
        expect(instance).not_to be_valid
      end

      it "has a validation error" do
        expect(instance).to have_validation_error("#/field/%24ref")
      end
    end
  end
end
