# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::Url do
  let(:valid_input) { "test: this" }
  let(:unparsable_input) { "*invalid: yaml" }
  let(:url) { "https://example.com/openapi.yaml" }

  before do
    stub_request(:get, %r{^https://example.com}).to_return(body: valid_input)
  end

  describe "#available?" do
    it "returns true when the URL returns successfully and has valid contents" do
      expect(described_class.new(url).available?).to be true
    end

    it "returns false when the URL returns successfully and has unparsable contents" do
      stub_request(:get, url).to_return(body: unparsable_input)
      expect(described_class.new(url).available?).to be false
    end

    it "returns false when the URL is not available" do
      stub_request(:get, url).to_return(status: 404)
      expect(described_class.new(url).available?).to be false
    end
  end

  describe "#access_error" do
    it "returns nil for a URL returns successfully" do
      expect(described_class.new(url).access_error).to be_nil
    end

    it "returns an inaccessible input error when URL isn't available" do
      stub_request(:get, url).to_return(status: 404)
      expect(described_class.new(url).access_error)
        .to be_a(Openapi3Parser::Error::InaccessibleInput)
    end
  end

  describe "#parse_error" do
    it "returns nil for a URL that returns valid input" do
      expect(described_class.new(url).parse_error).to be_nil
    end

    it "returns an unparsable input error when URL has unparsable contents" do
      stub_request(:get, url).to_return(body: unparsable_input)
      expect(described_class.new(url).parse_error)
        .to be_a(Openapi3Parser::Error::UnparsableInput)
    end
  end

  describe "#contents" do
    it "returns the responses contents after parsing" do
      stub_request(:get, url).to_return(body: "field: value")
      expect(described_class.new(url).contents).to eq({ "field" => "value" })
    end

    it "raises an error when the response contents are unparsable" do
      stub_request(:get, url).to_return(body: unparsable_input)
      expect { described_class.new(url).contents }
        .to raise_error(Openapi3Parser::Error::UnparsableInput)
    end

    it "raises an error when the URL isn't accessible" do
      stub_request(:get, url).to_return(status: 404)
      expect { described_class.new(url).contents }
        .to raise_error(Openapi3Parser::Error::InaccessibleInput)
    end
  end

  describe "#resolve_next" do
    it "returns a new source input URL that is relative to the original URL" do
      url = "https://example.com/path/to/openapi.yaml"
      reference_url = "../new-file.yaml#/object"
      reference = Openapi3Parser::Source::Reference.new(reference_url)
      expected_url = "https://example.com/path/new-file.yaml"

      source_input = described_class.new(url).resolve_next(reference)
      expect(source_input).to eq described_class.new(expected_url)
    end
  end

  describe "#==" do
    it "returns true for the same class and same url" do
      other = described_class.new(url)
      expect(described_class.new(url)).to eq other
    end

    it "returns false for the same class and different url" do
      other_url = "https://example.com/different"
      other = described_class.new(other_url)
      expect(described_class.new(url)).not_to eq other
    end

    it "returns false for a different class" do
      other = Openapi3Parser::SourceInput::Raw.new({})
      expect(described_class.new(url)).not_to eq other
    end
  end

  describe "#relative_to" do
    it "returns a string representing the relative path difference" do
      instance = described_class.new("https://example.com/path/to/file.yaml")
      other = described_class.new("https://example.com/file.yaml")
      expect(instance.relative_to(other)).to eq "path/to/file.yaml"
    end

    it "represents a lower directory with .." do
      instance = described_class.new("https://example.com/file.yaml")
      other = described_class.new("https://example.com/path/to/file.yaml")
      expect(instance.relative_to(other)).to eq "../../file.yaml"
    end

    it "maintains query strings" do
      instance = described_class.new("https://example.com/file.yaml?test=1")
      other = described_class.new("https://example.com/file.yaml?test=2")
      expect(instance.relative_to(other)).to eq "file.yaml?test=1"
    end

    it "returns the full URL when there isn't a relation in common" do
      url = "https://other-example.com/file.yaml"
      stub_request(:get, /other-example/)

      instance = described_class.new(url)
      other = described_class.new("https://example.com/file.yaml")

      expect(instance.relative_to(other)).to eq url
    end

    it "returns the full URL when compared to a file input" do
      instance = described_class.new(url)
      other = Openapi3Parser::SourceInput::File.new("/path/to/file")
      expect(instance.relative_to(other)).to eq url
    end

    context "when compared to a raw input" do
      it "compares relative to the base URL if one exists" do
        instance = described_class.new("https://example.com/path/file.yaml")
        other = Openapi3Parser::SourceInput::Raw.new(
          {},
          base_url: "https://example.com/file.yaml"
        )
        expect(instance.relative_to(other)).to eq "path/file.yaml"
      end

      it "returns the original URL if there isn't a base URL" do
        instance = described_class.new(url)
        other = Openapi3Parser::SourceInput::Raw.new({})
        expect(instance.relative_to(other)).to eq url
      end
    end
  end
end
