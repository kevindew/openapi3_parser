# frozen_string_literal: true

require "support/helpers/context"
require "support/helpers/source"

RSpec.describe Openapi3Parser::Source::ResolvedReference do
  include Helpers::Context
  include Helpers::Source

  let(:instance) do
    described_class.new(source_location: source_location,
                        object_type: object_type,
                        reference_registry: reference_registry)
  end

  let(:source_location) do
    create_source_location({ field: factory_input },
                           pointer_segments: %w[field])
  end

  let(:object_type) { "Openapi3Parser::NodeFactory::Contact" }

  let(:factory_input) { { name: "John" } }

  let(:reference_registry) do
    Openapi3Parser::Document::ReferenceRegistry.new.tap do |registry|
      context = create_node_factory_context(
        {},
        document: source_location.source.document
      )

      registry.register(Openapi3Parser::NodeFactory::Contact,
                        source_location,
                        context)
    end
  end

  describe "#errors" do
    subject { instance.errors }

    context "when the source file is not available" do
      before do
        allow(source_location.source)
          .to receive(:available?)
          .and_return(false)

        allow(source_location.source)
          .to receive(:relative_to_root)
          .and_return("../openapi.yml")
      end

      it { is_expected.to include("Failed to open source ../openapi.yml") }
    end

    context "when the reference pointer is not in the source" do
      let(:source_location) do
        create_source_location({ field: factory_input },
                               pointer_segments: %w[different])
      end

      it { is_expected.to include("#/different is not defined") }
    end

    context "when the factory is not valid" do
      let(:factory_input) { { unexpected: "blah" } }

      it do
        expect(subject)
          .to include("#/field does not resolve to a valid object")
      end
    end

    context "when the factory is valid" do
      it { is_expected.to be_empty }
    end
  end

  describe "#valid?" do
    subject { instance.valid? }

    context "when the resolved reference is valid" do
      it { is_expected.to be true }
    end

    context "when the resolved reference is invalid" do
      let(:factory_input) { { unexpected: "blah" } }

      it { is_expected.to be false }
    end
  end

  describe "#factory" do
    subject { instance.factory }

    context "when the reference registry has the factory" do
      it { is_expected.to be_a(Openapi3Parser::NodeFactory::Object) }
    end

    context "when the reference registry does not have the factory" do
      let(:reference_registry) do
        Openapi3Parser::Document::ReferenceRegistry.new
      end

      it "raises an error" do
        expect { instance.factory }
          .to raise_error(Openapi3Parser::Error,
                          "Unregistered node factory at #/field")
      end
    end
  end
end
