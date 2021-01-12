# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::Raw do
  let(:unparsable_input) { "*invalid: yaml" }

  describe "#available?" do
    it "returns true when input is valid" do
      expect(described_class.new({}).available?).to be true
    end

    it "returns false when input is unparsable" do
      expect(described_class.new(unparsable_input).available?).to be false
    end
  end

  describe "#parse_error" do
    it "returns nil when input is valid" do
      expect(described_class.new({}).parse_error).to be_nil
    end

    it "returns an error object when input is invalid" do
      expect(described_class.new(unparsable_input).parse_error)
        .to be_a(Openapi3Parser::Error::UnparsableInput)
    end
  end

  describe "#contents" do
    it "returns the input" do
      expect(described_class.new({}).contents).to eq({})
    end

    it "raises an error when input is unparsable" do
      expect { described_class.new(unparsable_input).contents }
        .to raise_error(Openapi3Parser::Error::UnparsableInput)
    end
  end

  describe "#resolve_next" do
    it "returns a new source input based on the given reference" do
      url = "https://example.com/openapi"
      reference = Openapi3Parser::Source::Reference.new(url)
      stub_request(:get, url)
      source_input = described_class.new({}).resolve_next(reference)
      expect(source_input).to eq Openapi3Parser::SourceInput::Url.new(url)
    end
  end

  describe "#==" do
    it "returns true for the same class and same input" do
      other = described_class.new({ field: "value" })

      expect(described_class.new({ field: "value" })).to eq other
    end

    it "returns false for the same class and different input" do
      other = described_class.new({ field: "value" })

      expect(described_class.new({})).not_to eq other
    end

    it "returns false for a different class" do
      other = Openapi3Parser::SourceInput::File.new("test.yml")

      expect(described_class.new({})).not_to eq other
    end
  end
end
