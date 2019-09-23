# frozen_string_literal: true

require "support/helpers/source"

RSpec.describe Openapi3Parser::Document::ReferenceRegistry do
  include Helpers::Source

  describe "#resolve" do
    let(:unbuilt_factory) { Openapi3Parser::NodeFactory::Contact }

    let(:source_location) do
      create_source_location({ contact: { name: "John Smith" } },
                             pointer_segments: %w[contact])
    end

    let(:reference_location) do
      create_source_location({}, document: source_location.source.document)
    end

    let(:instance) { described_class.new }

    subject(:resolve) do
      instance.resolve(unbuilt_factory, source_location, reference_location)
    end

    context "when the source and factory are not registered" do
      it "returns a built factory" do
        expect(resolve).to be_a(Openapi3Parser::NodeFactory::Contact)
      end

      it "registers the source" do
        expect { resolve }
          .to change { instance.sources }
          .to [source_location.source]
      end

      it "registers the factory" do
        expect { resolve }
          .to change { instance.factories }
          .to [an_instance_of(Openapi3Parser::NodeFactory::Contact)]
      end
    end

    context "when the source is registered" do
      before do
        instance.resolve(
          Openapi3Parser::NodeFactory::Info,
          source_location,
          reference_location
        )
      end

      it "doesn't update the sources" do
        expect { resolve }
          .not_to(change { instance.sources })
      end
    end

    context "when the factory is already registered" do
      let!(:previous_factory) do
        instance.resolve(unbuilt_factory, source_location, reference_location)
      end

      it { is_expected.to be(previous_factory) }

      it "doesn't update the factories" do
        expect { resolve }
          .not_to(change { instance.factories })
      end
    end

    context "when the source is registered for a different factory type" do
      before do
        instance.resolve(Openapi3Parser::NodeFactory::Info,
                         source_location,
                         reference_location)
      end

      it { is_expected.to be_a(Openapi3Parser::NodeFactory::Contact) }

      it "registers the factory" do
        expect { resolve }
          .to change { instance.factories }
          .to include(an_instance_of(Openapi3Parser::NodeFactory::Contact))
      end
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
