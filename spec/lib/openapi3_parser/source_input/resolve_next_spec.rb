# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::ResolveNext do
  before do
    allow(File).to receive(:read).and_return("")
    stub_request(:get, /example/)
  end

  describe "#call" do
    it "can return a file source input based on the working directory" do
      source_input = described_class.call(
        Openapi3Parser::Source::Reference.new("other.yaml#/test"),
        Openapi3Parser::SourceInput::Raw.new({}),
        working_directory: "/file"
      )

      expect(source_input)
        .to eq Openapi3Parser::SourceInput::File.new("/file/other.yaml")
    end

    it "can return a URL source input based on the base URL" do
      source_input = described_class.call(
        Openapi3Parser::Source::Reference.new("other.yaml#/test"),
        Openapi3Parser::SourceInput::Raw.new({}),
        base_url: "https://example.org/path/to/file.yaml"
      )

      expect(source_input)
        .to eq Openapi3Parser::SourceInput::Url.new("https://example.org/path/to/other.yaml")
    end

    it "returns an unchanged URL for an absolute reference" do
      source_input = described_class.call(
        Openapi3Parser::Source::Reference.new("https://example.org/file.yaml"),
        Openapi3Parser::SourceInput::Raw.new({}),
        base_url: "https://example.org/path/to/file.yaml"
      )

      expect(source_input)
        .to eq Openapi3Parser::SourceInput::Url.new("https://example.org/file.yaml")
    end

    it "returns the current source input when the reference is just a fragment" do
      current_source_input = Openapi3Parser::SourceInput::Raw.new({})
      source_input = described_class.call(
        Openapi3Parser::Source::Reference.new("#/test"),
        current_source_input
      )

      expect(source_input).to eq current_source_input
    end
  end
end
