# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::ResolvedReference do
  let(:object_type) { "Openapi3Parser::NodeFactory::Contact" }

  describe "#errors" do
    it "returns an empty array when there are no errors" do
      source_location = create_source_location({ openapi: "3.0.0", field: { name: "John" } },
                                               pointer_segments: %w[field])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(
        source_location:,
        object_type:,
        reference_registry:
      )

      expect(instance.errors).to eq []
    end

    it "includes an error when a source isn't available" do
      source_location = create_source_location
      allow(source_location.source).to receive_messages(available?: false, relative_to_root: "../openapi.yml")

      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)

      expect(instance.errors).to include("Failed to open source ../openapi.yml")
    end

    it "includes an error when a pointer isn't in the source" do
      source_location = create_source_location({ openapi: "3.0.0", field: { name: "John" } },
                                               pointer_segments: %w[different])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)

      expect(instance.errors).to include("#/different is not defined")
    end

    it "includes an error when the factory doesn't reference a valid object" do
      source_location = create_source_location({ openapi: "3.0.0", field: { unexpected: "Blah" } },
                                               pointer_segments: %w[field])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)

      expect(instance.errors).to include("#/field does not resolve to a valid object")
    end
  end

  describe "#valid?" do
    it "returns true when valid" do
      source_location = create_source_location({ openapi: "3.0.0", field: { name: "John" } },
                                               pointer_segments: %w[field])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)
      expect(instance).to be_valid
    end

    it "returns false when not" do
      source_location = create_source_location({ openapi: "3.0.0", field: { unexpected: "Blah" } },
                                               pointer_segments: %w[field])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)
      expect(instance).not_to be_valid
    end
  end

  describe "#factory" do
    it "returns a factory for a registered reference" do
      source_location = create_source_location({ openapi: "3.0.0", field: { name: "John" } },
                                               pointer_segments: %w[field])
      reference_registry = create_reference_registry(source_location)
      instance = described_class.new(source_location:,
                                     object_type:,
                                     reference_registry:)
      expect(instance.factory).to be_a(Openapi3Parser::NodeFactory::Contact)
    end

    it "raises an error when a reference is registered" do
      source_location = create_source_location({ openapi: "3.0.0", field: { name: "John" } },
                                               pointer_segments: %w[field])
      instance = described_class.new(
        source_location:,
        object_type:,
        reference_registry: Openapi3Parser::Document::ReferenceRegistry.new
      )

      expect { instance.factory }
        .to raise_error(Openapi3Parser::Error, "Unregistered node factory at #/field")
    end
  end

  def create_reference_registry(source_location)
    Openapi3Parser::Document::ReferenceRegistry.new.tap do |registry|
      factory_context = create_node_factory_context(
        {},
        document: source_location.source.document
      )

      registry.register(Openapi3Parser::NodeFactory::Contact,
                        source_location,
                        factory_context)
    end
  end
end
