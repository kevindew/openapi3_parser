# frozen_string_literal: true

require "support/helpers/source"

RSpec.describe Openapi3Parser::Source::Location do
  include Helpers::Source

  let(:source) { create_source({}) }
  let(:document) { source.document }
  let(:pointer_segments) { %w[field] }
  let(:instance) { described_class.new(source, pointer_segments) }

  describe ".next_field" do
    it "returns a source location relatively appened to a segment" do
      location = described_class.new(source, %w[field])
      next_field = described_class.next_field(location, "next")

      expect(next_field).to eq described_class.new(source, %w[field next])
    end
  end

  describe "#==" do
    it "is true for same source and pointer" do
      expect(instance).to eq described_class.new(source, pointer_segments)
    end

    it "is false for a different class" do
      expect(instance).not_to eq 1
    end

    it "is false for a different pointer" do
      expect(instance).not_to eq described_class.new(source, %w[different])
    end
  end

  describe "#to_s" do
    subject { instance.to_s }

    context "for a root source" do
      it { is_expected.to eq "#/field" }
    end

    context "for a none root source" do
      let(:root_source) do
        source_input = create_file_source_input(path: "/path/to/file.yml")
        create_source(source_input)
      end

      let(:source) do
        source_input = create_file_source_input(path: "/path/test.yml")
        create_source(source_input, document: root_source.document)
      end

      it { is_expected.to eq "../test.yml#/field" }
    end
  end

  describe "#data" do
    subject { instance.data }

    let(:source) { create_source({ field: 1234 }) }

    it { is_expected.to eq 1234 }
  end

  describe "#pointer_defined?" do
    subject { instance.pointer_defined? }

    context "when there is data at the pointer" do
      let(:source) { create_source({ field: 1234 }) }

      it { is_expected.to be true }
    end

    context "when there is data at the pointer" do
      let(:source) { create_source({ not_field: 1234 }) }

      it { is_expected.to be false }
    end
  end

  describe "#source_available?" do
    subject { instance.source_available? }

    let(:url) { "http://example.com/test" }
    let(:source) do
      create_source(Openapi3Parser::SourceInput::Url.new(url),
                    document: create_source({}).document)
    end

    context "when the source can be opened" do
      before do
        stub_request(:get, url).to_return(body: {}.to_json, status: 200)
      end

      it { is_expected.to be true }
    end

    context "when the source can't be opened" do
      before { stub_request(:get, url).to_return(status: 404) }

      it { is_expected.to be false }
    end
  end
end
