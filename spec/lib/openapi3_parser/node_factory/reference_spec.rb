# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Reference do
  include Helpers::Context

  let(:input) { { "$ref" => "#/contact" } }
  let(:node_factory_context) do
    create_node_factory_context(input, document_input: { contact: {} })
  end
  let(:factory) { Openapi3Parser::NodeFactory::Contact }
  let(:instance) { described_class.new(node_factory_context, factory) }

  describe "#node" do
    subject(:node) do
      node_context = node_factory_context_to_node_context(node_factory_context)
      instance.node(node_context)
    end

    context "when the reference is valid" do
      it { is_expected.to be_a(Openapi3Parser::Node::Contact) }
    end

    context "when the reference is incorrect type" do
      let(:input) { "" }

      it "raises an error" do
        expect { node }.to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end

    context "when the reference is missing fields" do
      let(:input) { {} }

      it "raises an error" do
        expect { node }.to raise_error(Openapi3Parser::Error::MissingFields)
      end
    end

    context "when the reference is invalid" do
      let(:input) { { "$ref" => "invalid reference" } }

      it "raises an error" do
        expect { node }.to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end

    context "when the reference is syntactically correct but unresolvable" do
      let(:input) { { "$ref" => "#/unresolvable" } }

      it "raises an error" do
        expect { node }.to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end

  describe "#valid?" do
    subject { instance.valid? }
    context "when input is valid" do
      it { is_expected.to be true }
    end

    context "when input is invalid" do
      let(:input) { {} }
      it { is_expected.to be false }
    end
  end

  describe "#errors" do
    subject { instance.errors }
    context "when input is valid" do
      it { is_expected.to be_empty }
    end

    context "when it is missing a $ref" do
      let(:input) { {} }
      it "has a validation error" do
        expect(instance)
          .to have_validation_error("#/",
                                    "Missing required fields: $ref")
      end
    end
  end

  describe "#resolves?" do
    subject { instance.resolves?(control_factory) }

    let(:factory) do
      Openapi3Parser::NodeFactory::OptionalReference.new(
        Openapi3Parser::NodeFactory::Contact
      )
    end

    let(:input) { { "$ref" => "#/contact_2" } }

    let(:node_factory_context) do
      create_node_factory_context(input,
                                  document_input: document_input,
                                  pointer_segments: %w[contact_1])
    end

    let(:control_factory) do
      # As references need to be registered and this happens in the process
      # of creating a reference node we need to check reference loop using
      # a factory from the reference registry
      node_factory_context.source.reference_registry.factories.first
    end

    context "when a reference can reach an object" do
      let(:document_input) do
        {
          contact_1: { "$ref" => "#/contact_2" },
          contact_2: { "$ref" => "#/contact_3" },
          contact_3: {}
        }
      end

      it { is_expected.to be true }
    end

    context "when a reference never reaches an object" do
      let(:document_input) do
        {
          contact_1: { "$ref" => "#/contact_2" },
          contact_2: { "$ref" => "#/contact_3" },
          contact_3: { "$ref" => "#/contact_1" }
        }
      end

      it { is_expected.to be false }
    end
  end
end
