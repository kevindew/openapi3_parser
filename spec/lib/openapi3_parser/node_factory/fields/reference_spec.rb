# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Fields::Reference do
  let(:factory_class) { Openapi3Parser::NodeFactory::Contact }
  let(:factory_context) do
    create_node_factory_context(
      "#/reference",
      document_input: document_input,
      pointer_segments: %w[field $ref]
    )
  end
  let(:document_input) { {} }

  describe "#resolved_input" do
    it "raises an error because a reference itself isn't resolved" do
      instance = described_class.new(factory_context, factory_class)
      expect { instance.resolved_input }
        .to raise_error(Openapi3Parser::Error, "References can't have a resolved input")
    end
  end

  describe "#node" do
    let(:instance) { described_class.new(factory_context, factory_class) }
    let(:node_context) { node_factory_context_to_node_context(factory_context) }

    it "raises an error because references are a replaced node" do
      expect { instance.node(node_context) }
        .to raise_error(Openapi3Parser::Error, "Reference fields can't be built as a node")
    end
  end

  describe "validations" do
    let(:instance) { described_class.new(factory_context, factory_class) }

    context "when the reference can be resolved" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it "is valid" do
        expect(instance).to be_valid
      end
    end

    context "when the reference can't be resolved" do
      let(:document_input) do
        { "reference" => { "url" => "invalid url" } }
      end

      it "is invalid" do
        expect(instance).not_to be_valid
        expect(instance).to have_validation_error("#/field/%24ref")
      end
    end
  end
end
