# frozen_string_literal: true

require "support/helpers/context"
require "support/helpers/source"

RSpec.describe Openapi3Parser::Node::Context do
  include Helpers::Context
  include Helpers::Source

  describe ".root" do
    let(:factory_context) { create_node_factory_context({}) }

    it "returns an instance of context" do
      expect(described_class.root(factory_context))
        .to be_a(described_class)
    end

    it "has a document location of root" do
      context = described_class.root(factory_context)

      expect(context.document_location.to_s).to eq "#/"
    end
  end

  describe ".next_field" do
    subject(:context) do
      described_class.next_field(parent_context, field, factory_context)
    end

    let(:parent_context) { create_node_context({}) }
    let(:factory_context) { create_node_factory_context({}) }
    let(:field) { "key" }

    it "has a document location of '#/key'" do
      expect(context.document_location.to_s).to eq "#/key"
    end
  end

  describe ".resolved_reference" do
    subject(:context) do
      described_class.resolved_reference(current_context,
                                         reference_factory_context)
    end

    let(:current_context) do
      create_node_context({}, pointer_segments: %w[field])
    end

    let(:reference_factory_context) do
      source_location = create_source_location(
        {},
        document: current_context.document,
        pointer_segments: %w[data]
      )

      reference_location = create_source_location(
        {},
        document: current_context.document,
        pointer_segments: %w[field $ref]
      )

      Openapi3Parser::NodeFactory::Context.new(
        "data",
        source_location: source_location,
        reference_locations: [reference_location]
      )
    end

    it "has the referenced input" do
      expect(context.input).to eq "data"
    end

    it "maintains the document location" do
      expect(context.document_location.to_s)
        .to eq "#/field"
    end

    it "knows the source location is where the referenced data is" do
      expect(context.source_location.to_s)
        .to eq "#/data"
    end
  end
end
