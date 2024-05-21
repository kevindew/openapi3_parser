# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Fields::Reference do
  let(:factory_class) { Openapi3Parser::NodeFactory::Contact }
  let(:factory_context) do
    create_node_factory_context(
      "#/reference",
      document_input:,
      pointer_segments: %w[field $ref]
    )
  end

  describe "#resolved_input" do
    let(:instance) { described_class.new(factory_context, factory_class) }

    context "when reference can be resolved" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it "returns the resolved input" do
        expect(instance.resolved_input)
          .to match(hash_including({ "name" => "Joe" }))
      end
    end

    context "when reference can't be resolved" do
      let(:document_input) do
        { "not_reference" => {} }
      end

      it "returns nil" do
        expect(instance.resolved_input).to be_nil
      end
    end
  end

  describe "#node" do
    let(:instance) { described_class.new(factory_context, factory_class) }
    let(:node_context) { node_factory_context_to_node_context(factory_context) }

    context "when the reference can be resolved" do
      let(:document_input) do
        { "reference" => { "name" => "Joe" } }
      end

      it "returns an instance of the referenced node" do
        expect(instance.node(node_context))
          .to be_a(Openapi3Parser::Node::Contact)
      end
    end

    context "when the reference can't be resolved" do
      let(:document_input) do
        { "reference" => { "url" => "invalid url" } }
      end

      it "raises an error" do
        expect { instance.node(node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
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
