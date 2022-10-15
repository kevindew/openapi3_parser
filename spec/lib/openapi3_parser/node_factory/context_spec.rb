# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Context do
  describe ".root" do
    let(:input) { {} }
    let(:source) { create_source(input) }

    it "returns a context instance" do
      expect(described_class.root(input, source)).to be_a(described_class)
    end

    it "has no reference locations" do
      instance = described_class.root(input, source)
      expect(instance.reference_locations).to be_empty
    end

    it "has a source location of the document root" do
      instance = described_class.root(input, source)
      expect(instance.source_location.pointer.to_s).to eq "#/"
    end
  end

  describe ".next_field" do
    let(:input) { { "key" => "value" } }
    let(:parent_context) do
      create_node_factory_context(input, document_input: input)
    end

    it "returns a context instance" do
      expect(described_class.next_field(parent_context, "key"))
        .to be_a(described_class)
    end

    it "has an input matching the value at the field" do
      instance = described_class.next_field(parent_context, "key")
      expect(instance.input).to eq "value"
    end

    it "has a pointer fragment based on the field" do
      instance = described_class.next_field(parent_context, "key")
      expect(instance.source_location.pointer.to_s).to eq "#/key"
    end

    it "can override the input from the context" do
      instance = described_class.next_field(parent_context, "key", "data")
      expect(instance.input).to eq "data"
    end
  end

  describe ".resolved_reference" do
    let(:input) { "data" }
    let(:source_location) { create_source_location(input) }

    let(:reference_context) do
      create_node_factory_context({},
                                  document: source_location.source.document)
    end

    it "returns a context instance" do
      instance = described_class.resolved_reference(
        reference_context, source_location: source_location
      )
      expect(instance).to be_a(described_class)
    end

    it "has the resolved reference data" do
      instance = described_class.resolved_reference(
        reference_context, source_location: source_location
      )
      expect(instance.input).to eq "data"
    end

    it "has the resolved reference location" do
      instance = described_class.resolved_reference(
        reference_context, source_location: source_location
      )
      expect(instance.source_location).to eq source_location
    end

    it "is knows the location of the reference" do
      instance = described_class.resolved_reference(
        reference_context, source_location: source_location
      )
      expect(instance.reference_locations)
        .to eq [reference_context.source_location]
    end
  end

  describe "#location_summary" do
    it "returns a string representation of the pointer segments" do
      source_location = create_source_location({}, pointer_segments: %w[path to field])
      instance = described_class.new({}, source_location: source_location)
      expect(instance.location_summary).to eq "#/path/to/field"
    end
  end

  describe "#resolve_reference" do
    it "returns a resolved reference object" do
      input = {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Test",
          "version" => "1.0"
        },
        "paths" => {},
        "components" => {
          "schemas" => {
            "item" => { "type" => "object" }
          }
        }
      }
      source_location = create_source_location(input)
      instance = described_class.new({}, source_location: source_location)
      resolved_reference = instance.resolve_reference("#/components/schemas/item",
                                                      Openapi3Parser::NodeFactory::Schema::V3_0)
      expect(resolved_reference)
        .to be_a(Openapi3Parser::Source::ResolvedReference)
    end
  end

  describe "#openapi_version" do
    it "returns the document's OpenAPI version" do
      input = {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Test",
          "version" => "1.0"
        },
        "paths" => {}
      }
      source_location = create_source_location(input)

      instance = described_class.new({}, source_location: source_location)
      expect(instance.openapi_version).to eq("3.0")
    end
  end
end
