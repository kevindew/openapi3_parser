# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::Placeholder do
  include Helpers::Context

  let(:node_factory) do
    Openapi3Parser::NodeFactory::Contact.new(create_node_factory_context({}))
  end

  describe ".resolve" do
    context "when given a placeholder" do
      let(:placeholder) do
        described_class.new(node_factory, "contact", create_node_context({}))
      end

      it "returns the node of the item" do
        expect(described_class.resolve(placeholder))
          .to be_instance_of(Openapi3Parser::Node::Contact)
      end
    end

    context "when not given a placeholder" do
      it "returns the item" do
        expect(described_class.resolve(3)).to be 3
      end
    end
  end

  describe ".each" do
    let(:placeholder) do
      described_class.new(node_factory, "contact", create_node_context({}))
    end

    context "when node_data is a hash" do
      let(:node_data) do
        {
          "a" => "this",
          "b" => placeholder
        }
      end

      it "returns an enumerator of the resolved values" do
        enumerator = described_class.each(node_data)
        expect(enumerator).to be_instance_of(Enumerator)

        expect(enumerator.to_h)
          .to match "a" => "this",
                    "b" => an_instance_of(Openapi3Parser::Node::Contact)
      end

      it "can be passed a block to iterate the items" do
        keys = []
        values = []

        described_class.each(node_data) do |key, value|
          keys << key
          values << value
        end

        expect(keys).to eq %w[a b]
        expect(values)
          .to match ["this", an_instance_of(Openapi3Parser::Node::Contact)]
      end
    end

    context "when node_data is an array" do
      let(:node_data) { ["this", placeholder] }

      it "returns an enumerator of the resolved values" do
        enumerator = described_class.each(node_data)
        expect(enumerator).to be_instance_of(Enumerator)

        expect(enumerator.to_a)
          .to match ["this", an_instance_of(Openapi3Parser::Node::Contact)]
      end

      it "can be passed a block to iterate the items" do
        values = []
        described_class.each(node_data) { |value| values << value }

        expect(values)
          .to match ["this", an_instance_of(Openapi3Parser::Node::Contact)]
      end
    end
  end

  describe "#node" do
    let(:instance) do
      described_class.new(node_factory,
                          "contact",
                          create_node_context({}, pointer_segments: %w[root]))
    end

    it "returns a node" do
      expect(instance.node).to be_instance_of(Openapi3Parser::Node::Contact)
    end

    it "sets the document location relative to parent context" do
      node = instance.node
      expect(node.node_context.document_location.to_s)
        .to eq "#/root/contact"
    end
  end
end
