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

  describe "#==" do
    let(:document_location) do
      create_source_location({}, pointer_segments: %w[field_a])
    end

    let(:source_location) do
      create_source_location({},
                             document: document_location.source.document,
                             pointer_segments: %w[ref_a])
    end

    subject do
      described_class.new({},
                          document_location: document_location,
                          source_location: source_location)
    end

    context "when document_locations, input and source locations match" do
      let(:other) do
        described_class.new({},
                            document_location: document_location,
                            source_location: source_location)
      end

      it { is_expected.to eq(other) }
    end

    context "when one of these differ" do
      let(:other) do
        other_location = create_source_location(
          {},
          document: document_location.source.document,
          pointer_segments: %w[field_b]
        )

        described_class.new({},
                            document_location: other_location,
                            source_location: source_location)
      end

      it { is_expected.not_to eq(other) }
    end
  end

  describe "#same_data_and_source?" do
    let(:source_location) do
      create_source_location({}, pointer_segments: %w[ref_a])
    end

    let(:document_location) do
      create_source_location({},
                             document: source_location.source.document,
                             pointer_segments: %w[field_a])
    end

    let(:other_document_location) do
      create_source_location({},
                             document: source_location.source.document,
                             pointer_segments: %w[field_b])
    end

    let(:instance) do
      described_class.new({},
                          document_location: document_location,
                          source_location: source_location)
    end

    subject { instance.same_data_and_source?(other) }

    context "when input and source locations match" do
      let(:other) do
        described_class.new({},
                            document_location: other_document_location,
                            source_location: source_location)
      end

      it { is_expected.to be true }
    end

    context "when one of these differ" do
      let(:other) do
        described_class.new({ different: "data" },
                            document_location: other_document_location,
                            source_location: source_location)
      end

      it { is_expected.to be false }
    end
  end
end
