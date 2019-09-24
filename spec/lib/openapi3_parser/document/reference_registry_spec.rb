# frozen_string_literal: true

require "support/helpers/context"
require "support/helpers/source"

RSpec.describe Openapi3Parser::Document::ReferenceRegistry do
  include Helpers::Context
  include Helpers::Source

  describe "#register" do
    let(:unbuilt_factory) { Openapi3Parser::NodeFactory::Contact }

    let(:source_location) do
      create_source_location({ contact: { name: "John Smith" } },
                             pointer_segments: %w[contact])
    end

    let(:reference_factory_context) do
      create_node_factory_context({},
                                  document: source_location.source.document)
    end

    let(:instance) { described_class.new }

    subject(:register) do
      instance.register(unbuilt_factory,
                        source_location,
                        reference_factory_context)
    end

    context "when the source and factory are not registered" do
      it "returns a built factory" do
        expect(register).to be_a(Openapi3Parser::NodeFactory::Contact)
      end

      it "registers the source" do
        expect { register }
          .to change { instance.sources }
          .to [source_location.source]
      end

      it "registers the factory" do
        expect { register }
          .to change { instance.factories }
          .to [an_instance_of(Openapi3Parser::NodeFactory::Contact)]
      end
    end

    context "when the source is registered" do
      before do
        instance.register(Openapi3Parser::NodeFactory::Info,
                          source_location,
                          reference_factory_context)
      end

      it "doesn't update the sources" do
        expect { register }
          .not_to(change { instance.sources })
      end
    end

    context "when the factory is already registered" do
      let!(:previous_factory) do
        instance.register(unbuilt_factory,
                          source_location,
                          reference_factory_context)
      end

      it { is_expected.to be(previous_factory) }

      it "doesn't update the factories" do
        expect { register }
          .not_to(change { instance.factories })
      end
    end

    context "when the source is registered for a different factory type" do
      before do
        instance.register(Openapi3Parser::NodeFactory::Info,
                          source_location,
                          reference_factory_context)
      end

      it { is_expected.to be_a(Openapi3Parser::NodeFactory::Contact) }

      it "registers the factory" do
        expect { register }
          .to change { instance.factories }
          .to include(an_instance_of(Openapi3Parser::NodeFactory::Contact))
      end
    end
  end

  describe "#factory" do
    let(:object_type) { "Openapi3Parser::NodeFactory::Contact" }

    let(:source_location) do
      create_source_location({ contact: { name: "John Smith" } },
                             pointer_segments: %w[contact])
    end

    let(:instance) { described_class.new }

    subject(:factory) { instance.factory(object_type, source_location) }

    context "when a factory is not registered" do
      it { is_expected.to be_nil }
    end

    context "when a factory is registered and matches the source location" do
      let(:reference_factory_context) do
        create_node_factory_context({},
                                    document: source_location.source.document)
      end

      let!(:existing_factory) do
        instance.register(Openapi3Parser::NodeFactory::Contact,
                          source_location,
                          reference_factory_context)
      end

      it "returns the existing factory" do
        expect(factory).to be_a(Openapi3Parser::NodeFactory::Contact)
        expect(factory).to be(existing_factory)
      end
    end

    context "when the factory doesn't match the source location" do
      let(:reference_factory_context) do
        create_node_factory_context({},
                                    document: source_location.source.document)
      end

      let(:reference_source_location) do
        create_source_location({ contact: { name: "John Doe" } },
                               document: source_location.source.document,
                               pointer_segments: %w[other_contact])
      end

      let!(:existing_factory) do
        instance.register(Openapi3Parser::NodeFactory::Contact,
                          reference_source_location,
                          reference_factory_context)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#freeze" do
    let(:instance) { described_class.new }
    before { instance.freeze }

    it "freezes the object" do
      expect(instance).to be_frozen
    end
  end
end
