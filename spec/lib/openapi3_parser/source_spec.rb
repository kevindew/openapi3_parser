# frozen_string_literal: true

require "support/helpers/context"
require "support/helpers/source"

RSpec.describe Openapi3Parser::Source do
  include Helpers::Context
  include Helpers::Source

  let(:source_data) do
    {
      "openapi" => "3.0.0",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {}
    }
  end

  let(:source_input) { document.root_source.source_input }

  let(:document) do
    Openapi3Parser::Document.new(create_raw_source_input(data: source_data))
  end

  let(:reference_registry) { Openapi3Parser::Document::ReferenceRegistry.new }

  let(:parent) { nil }

  let(:instance) do
    described_class.new(source_input, document, reference_registry, parent)
  end

  describe "#data" do
    it "deep-freezes the data" do
      expect(instance.data).to be_frozen
      expect(instance.data["info"]).to be_frozen
    end

    context "when given a symbol based hash" do
      let(:source_input) { create_raw_source_input(data: { key: "value" }) }

      it "converts symbols to strings" do
        expect(instance.data).to eq("key" => "value")
      end
    end

    context "when given array like data" do
      let(:source_input) do
        create_raw_source_input(data: { "key" => Set.new([1, 2, 3]) })
      end

      it "converts to a regular array" do
        expect(instance.data["key"]).to be_an(Array)
      end
    end
  end

  describe "#resolve_reference" do
    let(:reference) { "#/reference" }
    let(:unbuilt_factory) { Openapi3Parser::NodeFactory::Contact }
    let(:context) { create_node_factory_context({}) }

    it "returns a resolved reference" do
      resolved_reference = instance.resolve_reference(reference,
                                                      unbuilt_factory,
                                                      context)
      expect(resolved_reference)
        .to be_a(Openapi3Parser::Source::ResolvedReference)
    end

    context "when the reference is not recursive" do
      it "registers the reference" do
        expect(reference_registry).to receive(:register)
        instance.resolve_reference(reference,
                                   unbuilt_factory,
                                   context,
                                   recursive: false)
      end
    end

    context "when the reference is recursive" do
      it "doesn't register the reference" do
        expect(reference_registry).not_to receive(:register)
        instance.resolve_reference(reference,
                                   unbuilt_factory,
                                   context,
                                   recursive: true)
      end
    end
  end

  describe "#resolve_source" do
    context "when the reference is relative to the current source" do
      it "returns the current source" do
        reference = Openapi3Parser::Source::Reference.new("#/test")
        expect(instance.resolve_source(reference)).to be instance
      end
    end

    context "when the reference is to a different file" do
      it "returns the source" do
        url = "http://example.com/openapi"
        stub_request(:get, url).to_return(body: {}.to_json)

        reference = Openapi3Parser::Source::Reference.new("#{url}#/test")
        source = instance.resolve_source(reference)
        expect(source.source_input.url).to eq url
      end
    end
  end

  describe "#data_at_pointer" do
    subject { instance.data_at_pointer(json_pointer) }

    context "when a pointer is given and exists" do
      let(:json_pointer) { %w[info version] }

      it { is_expected.to eq "1.0.0" }
    end

    context "when a pointer is given and doesn't exist" do
      let(:json_pointer) { %w[non-existant] }

      it { is_expected.to be_nil }
    end

    context "when the pointer is empty" do
      let(:json_pointer) { [] }

      it { is_expected.to eq source_data }
    end
  end

  describe "#has_pointer?" do
    subject { instance.has_pointer?(json_pointer) }

    context "when a pointer is exists" do
      let(:json_pointer) { %w[info version] }

      it { is_expected.to be true }
    end

    context "when a pointer doesn't exist" do
      let(:json_pointer) { %w[non-existant] }

      it { is_expected.to be false }
    end
  end

  describe "#relative_to_root" do
    subject { instance.relative_to_root }

    let(:document) do
      Openapi3Parser::Document.new(
        create_raw_source_input(data: source_data,
                                working_directory: "/dir-1/dir-2")
      )
    end

    context "when it's the root document" do
      it { is_expected.to eq "" }
    end

    context "when it's not the root document" do
      let(:source_input) do
        create_file_source_input(data: {},
                                 path: "/dir-1/dir-3/dir-4/other.yml")
      end

      it { is_expected.to eq "../dir-3/dir-4/other.yml" }
    end
  end
end
