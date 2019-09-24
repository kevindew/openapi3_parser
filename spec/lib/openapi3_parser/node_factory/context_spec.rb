# frozen_string_literal: true

require "support/helpers/context"
require "support/helpers/source"

RSpec.describe Openapi3Parser::NodeFactory::Context do
  include Helpers::Context
  include Helpers::Source

  describe ".root" do
    subject(:context) { described_class.root(input, source) }

    let(:input) { {} }
    let(:source) { create_source(input) }

    it "has no references" do
      expect(context.reference_locations).to be_empty
    end

    it "has an empty pointer" do
      expect(context.source_location.pointer.to_s).to eq "#/"
    end
  end

  describe ".next_field" do
    subject(:context) { described_class.next_field(parent_context, field) }
    let(:input) { { "key" => "value" } }

    let(:parent_context) do
      create_node_factory_context(input, document_input: input)
    end

    let(:field) { "key" }

    it "has an input of 'value'" do
      expect(context.input).to eq "value"
    end

    it "has a pointer fragment of '#/key'" do
      expect(context.source_location.pointer.to_s).to eq "#/key"
    end
  end

  describe ".resolved_reference" do
    subject(:context) do
      described_class.resolved_reference(
        reference_context,
        source_location: source_location
      )
    end

    let(:input) { "data" }
    let(:source_location) { create_source_location(input) }

    let(:reference_context) do
      create_node_factory_context({},
                                  document: source_location.source.document)
    end

    it "has the resolved reference data" do
      expect(context.input).to eq source_location.data
    end

    it "has the resolved reference location" do
      expect(context.source_location).to eq source_location
    end

    it "is knows the location of the reference" do
      expect(context.reference_locations)
        .to eq [reference_context.source_location]
    end
  end

  describe "#location_summary" do
    subject do
      described_class.new({}, source_location: source_location)
                     .location_summary
    end

    let(:source_location) do
      create_source_location({}, pointer_segments: %w[path to field])
    end

    it { is_expected.to eq "#/path/to/field" }
  end

  describe "#resolve_reference" do
    subject do
      described_class.new({}, source_location: source_location)
                     .resolve_reference(reference, factory)
    end

    let(:source_location) do
      input = { "openapi" => "3.0.0",
                "info" => { "title" => "Test",
                            "version" => "1.0" },
                "paths" => {},
                "components" => {
                  "schemas" => {
                    "item" => { "type" => "object" }
                  }
                } }
      create_source_location(input)
    end

    let(:reference) { "#/components/schemas/item" }
    let(:factory) { Openapi3Parser::NodeFactory::Schema }

    it { is_expected.to be_a(Openapi3Parser::Source::ResolvedReference) }
  end
end
