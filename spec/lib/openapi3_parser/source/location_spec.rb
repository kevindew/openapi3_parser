# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::Location do
  describe ".next_field" do
    it "returns a source location relatively appened to a segment" do
      source = create_source({ "openapi" => "3.0.0" })
      location = described_class.new(source, %w[field])
      next_field = described_class.next_field(location, "next")

      expect(next_field).to eq described_class.new(source, %w[field next])
    end
  end

  describe "#==" do
    let(:source) { create_source({ "openapi" => "3.0.0" }) }
    let(:pointer_segments) { %w[field] }
    let(:instance) { described_class.new(source, pointer_segments) }

    it "returns true for same source and pointer" do
      expect(instance).to eq described_class.new(source, pointer_segments)
    end

    it "returns false for a different class" do
      expect(instance).not_to eq 1
    end

    it "returns false for a different pointer" do
      expect(instance).not_to eq described_class.new(source, %w[different])
    end
  end

  describe "#to_s" do
    it "returns a fragment for a root source" do
      instance = described_class.new(create_source({ "openapi" => "3.0.0" }), %w[path to segment])
      expect(instance.to_s).to eq "#/path/to/segment"
    end

    it "returns the relative path to the file with the segment for a non root source" do
      root_source = create_source(create_file_source_input(path: "/path/to/file.yml"))
      source = create_source(
        create_file_source_input(path: "/path/test.yml"),
        document: root_source.document
      )

      instance = described_class.new(source, %w[path to segment])
      expect(instance.to_s).to eq "../test.yml#/path/to/segment"
    end
  end

  describe "#data" do
    it "returns the data referenced at the pointer" do
      source = create_source({ openapi: "3.0.0", field: 1234 })
      instance = described_class.new(source, %w[field])
      expect(instance.data).to eq 1234
    end
  end

  describe "#pointer_defined?" do
    it "returns true when the pointer references defined data" do
      source = create_source({ openapi: "3.0.0", field: 1234 })
      instance = described_class.new(source, %w[field])
      expect(instance.pointer_defined?).to be true
    end

    it "returns false when the pointer references undefined data" do
      source = create_source({ openapi: "3.0.0", field: 1234 })
      instance = described_class.new(source, %w[not-field])
      expect(instance.pointer_defined?).to be false
    end
  end

  describe "#source_available?" do
    let(:url) { "http://example.com/test" }
    let(:source) do
      create_source(Openapi3Parser::SourceInput::Url.new(url),
                    document: create_source({ "openapi" => "3.0.0" }).document)
    end

    it "returns true when a source can be opened" do
      stub_request(:get, url).to_return(body: {}.to_json, status: 200)
      instance = described_class.new(source, %w[field])
      expect(instance.source_available?).to be true
    end

    it "returns false when a source cannot be opened" do
      stub_request(:get, url).to_return(status: 404)
      instance = described_class.new(source, %w[field])
      expect(instance.source_available?).to be false
    end
  end
end
