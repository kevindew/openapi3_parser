# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Fields::RecursiveReference do
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
    subject(:resolved_input) do
      described_class.new(factory_context, factory_class).resolved_input
    end

    context "when reference can be resolved" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it { is_expected.to be_a(described_class::RecursiveResolvedInput) }

      it "has the value" do
        expect(resolved_input["name"]).to eq "Joe"
      end
    end

    # this should never happen as for it to be recusive implies a nested
    # object
    context "when reference can't be resolved" do
      let(:document_input) do
        { "not_reference" => {} }
      end

      it "has a nil value" do
        expect(resolved_input.value).to be_nil
      end
    end
  end

  describe "#node" do
    let(:node_context) do
      node_factory_context_to_node_context(factory_context)
    end

    subject(:node) do
      described_class.new(factory_context, factory_class).node(node_context)
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
