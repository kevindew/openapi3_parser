# frozen_string_literal: true

RSpec.describe Openapi3Parser::Document::ReferenceRegistry do
  describe "#register" do
    let(:source_location) do
      create_source_location({ contact: { name: "John Smith" } },
                             pointer_segments: %w[contact])
    end

    let(:reference_factory_context) do
      create_node_factory_context({}, document: source_location.source.document)
    end

    let(:instance) { described_class.new }

    it "returns a built factory" do
      output = instance.register(Openapi3Parser::NodeFactory::Info,
                                 source_location,
                                 reference_factory_context)
      expect(output).to be_a(Openapi3Parser::NodeFactory::Info)
    end

    it "registers the source" do
      expect { instance.register(Openapi3Parser::NodeFactory::Info, source_location, reference_factory_context) }
        .to change(instance, :sources)
        .to include(source_location.source)
    end

    it "registers the factory" do
      expect { instance.register(Openapi3Parser::NodeFactory::Info, source_location, reference_factory_context) }
        .to change(instance, :factories)
        .to include(an_instance_of(Openapi3Parser::NodeFactory::Info))
    end

    it "doesn't change sources when the same source has already been registered" do
      instance.register(Openapi3Parser::NodeFactory::Contact,
                        source_location,
                        reference_factory_context)

      expect { instance.register(Openapi3Parser::NodeFactory::Info, source_location, reference_factory_context) }
        .not_to change(instance, :sources)
    end

    it "adds a factory even when the same source has already been registered" do
      instance.register(Openapi3Parser::NodeFactory::Contact,
                        source_location,
                        reference_factory_context)

      expect { instance.register(Openapi3Parser::NodeFactory::Info, source_location, reference_factory_context) }
        .to change(instance, :factories)
        .to include(an_instance_of(Openapi3Parser::NodeFactory::Contact))
    end

    it "doesn't change factories when the same factory is already registered" do
      instance.register(Openapi3Parser::NodeFactory::Info,
                        source_location,
                        reference_factory_context)

      expect { instance.register(Openapi3Parser::NodeFactory::Info, source_location, reference_factory_context) }
        .not_to change(instance, :factories)
    end
  end

  describe "#factory" do
    let(:object_type) { "Openapi3Parser::NodeFactory::Contact" }
    let(:source_location) do
      create_source_location({ contact: { name: "John Smith" } },
                             pointer_segments: %w[contact])
    end

    let(:instance) { described_class.new }

    it "returns an existing factory when one is registered" do
      reference_factory_context = create_node_factory_context(
        {},
        document: source_location.source.document
      )
      existing_factory = instance.register(Openapi3Parser::NodeFactory::Contact,
                                           source_location,
                                           reference_factory_context)

      expect(instance.factory(object_type, source_location))
        .to be_a(Openapi3Parser::NodeFactory::Contact)
        .and eq(existing_factory)
    end

    it "returns nil if an existing factory has a different source location" do
      reference_factory_context = create_node_factory_context(
        {},
        document: source_location.source.document
      )
      reference_source_location = create_source_location(
        { contact: { name: "John Doe" } },
        document: source_location.source.document,
        pointer_segments: %w[other_contact]
      )
      instance.register(Openapi3Parser::NodeFactory::Contact,
                        reference_source_location,
                        reference_factory_context)

      expect(instance.factory(object_type, source_location)).to be_nil
    end

    it "returns nil for an unregistered factory" do
      expect(instance.factory(object_type, source_location)).to be_nil
    end
  end

  describe "#freeze" do
    it "freezes the object" do
      instance = described_class.new
      expect { instance.freeze }
        .to change { instance.frozen? }
        .to true
    end
  end
end
