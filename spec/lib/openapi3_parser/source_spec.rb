# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source do
  describe "#data" do
    it "deep-freezes the data" do
      instance = create_source({ "info" => { "version" => "1.0.0" } })
      expect(instance.data).to be_frozen
      expect(instance.data["info"]).to be_frozen
    end

    it "normalises symbol keys to strings" do
      instance = create_source({ key: "value" })
      expect(instance.data).to eq({ "key" => "value" })
    end

    it "normalises array like data" do
      instance = create_source({ "key" => Set.new([1, 2, 3]) })
      expect(instance.data).to eq({ "key" => [1, 2, 3] })
    end
  end

  describe "#resolve_reference" do
    let(:instance) { create_source({}) }
    let(:reference) { "#/reference" }
    let(:unbuilt_factory) { Openapi3Parser::NodeFactory::Contact }
    let(:context) { create_node_factory_context({}) }

    it "returns a ResolvedReference object" do
      resolved_reference = instance.resolve_reference(reference,
                                                      unbuilt_factory,
                                                      context)
      expect(resolved_reference)
        .to be_a(Openapi3Parser::Source::ResolvedReference)
    end

    it "registers references that aren't recursive" do
      expect(instance.reference_registry).to receive(:register)
      instance.resolve_reference(reference,
                                 unbuilt_factory,
                                 context,
                                 recursive: false)
    end

    it "doesn't register recursive references" do
      expect(instance.reference_registry).not_to receive(:register)
      instance.resolve_reference(reference,
                                 unbuilt_factory,
                                 context,
                                 recursive: true)
    end
  end

  describe "#resolve_source" do
    let(:instance) { create_source({}) }

    it "returns current source when a reference is relative" do
      reference = Openapi3Parser::Source::Reference.new("#/test")
      expect(instance.resolve_source(reference)).to be(instance)
    end

    it "creates a new source for a reference to a different file" do
      url = "http://example.com/openapi"
      stub_request(:get, url).to_return(body: {}.to_json)

      reference = Openapi3Parser::Source::Reference.new("#{url}#/test")
      source = instance.resolve_source(reference)
      expect(source).not_to be(instance)
      expect(source.source_input.url).to eq(url)
    end
  end

  describe "#data_at_pointer" do
    let(:source_input) { { "info" => { "version" => "1.0.0" } } }
    let(:instance) { create_source(source_input) }

    it "returns the data at a given pointer" do
      expect(instance.data_at_pointer(%w[info version]))
        .to eq("1.0.0")
    end

    it "returns nil the when given a pointer to non existent data" do
      expect(instance.data_at_pointer(%w[blah blah]))
        .to be_nil
    end

    it "returns the full source input data when given an empty pointer" do
      expect(instance.data_at_pointer([])).to eq(source_input)
    end
  end

  describe "#has_pointer?" do
    let(:source_input) { { "info" => { "version" => "1.0.0" } } }
    let(:instance) { create_source(source_input) }

    it "returns true when there is data at a pointer" do
      expect(instance.has_pointer?(%w[info version])).to be(true)
    end

    it "returns false when there is not data at a pointer" do
      expect(instance.has_pointer?(["non-existent"])).to be(false)
    end
  end

  describe "#relative_to_root" do
    it "returns the a relative path from this source to the root source" do
      source_input = create_file_source_input(
        data: {},
        path: "/dir-1/dir-3/dir-4/other.yml"
      )

      document = Openapi3Parser::Document.new(
        create_raw_source_input(data: {}, working_directory: "/dir-1/dir-2")
      )

      instance = create_source(source_input, document:)
      expect(instance.relative_to_root).to eq("../dir-3/dir-4/other.yml")
    end

    it "returns an empty string when called on the root source" do
      root_source = create_source({})
      expect(root_source.relative_to_root).to eq("")
    end
  end
end
