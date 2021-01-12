# frozen_string_literal: true

RSpec.describe Openapi3Parser::SourceInput::File do
  let(:valid_input) { "test: this" }
  let(:unparsable_input) { "*invalid: yaml" }

  before { allow(File).to receive(:read).and_return(valid_input) }

  describe "#available?" do
    it "returns true when the file exists and has valid contents" do
      expect(described_class.new("/file").available?).to be true
    end

    it "returns false when the file exists and has unparsable contents" do
      allow(File).to receive(:read).and_return(unparsable_input)
      expect(described_class.new("/file").available?).to be false
    end

    it "returns false when the file can't be opened" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(described_class.new("/file").available?).to be false
    end
  end

  describe "#access_error" do
    it "returns nil for an available file" do
      expect(described_class.new("/file").access_error).to be_nil
    end

    it "returns an inaccessible input error when the file isn't available" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(described_class.new("/file").access_error)
        .to be_a(Openapi3Parser::Error::InaccessibleInput)
    end
  end

  describe "#parse_error" do
    it "returns nil for a file with valid input" do
      expect(described_class.new("/file").parse_error).to be_nil
    end

    it "returns an unparsable input error when the file contents aren't parsable" do
      allow(File).to receive(:read).and_return(unparsable_input)
      expect(described_class.new("/file").parse_error)
        .to be_a(Openapi3Parser::Error::UnparsableInput)
    end
  end

  describe "#contents" do
    it "returns the responses contents after parsing" do
      allow(File).to receive(:read).and_return("field: value")
      expect(described_class.new("/file").contents).to eq({ "field" => "value" })
    end

    it "raises an error when the file contents are unparsable" do
      allow(File).to receive(:read).and_return(unparsable_input)
      expect { described_class.new("/file").contents }
        .to raise_error(Openapi3Parser::Error::UnparsableInput)
    end

    it "raises an error when the file isn't accessible" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect { described_class.new("/file").contents }
        .to raise_error(Openapi3Parser::Error::InaccessibleInput)
    end
  end

  describe "#resolve_next" do
    it "returns a new source input URL that is relative to the original URL" do
      path = "/path/to/openapi.yaml"
      reference_path = "../new-file.yaml#/object"
      reference = Openapi3Parser::Source::Reference.new(reference_path)
      expected_path = "/path/new-file.yaml"

      source_input = described_class.new(path).resolve_next(reference)
      expect(source_input).to eq described_class.new(expected_path)
    end
  end

  describe "#==" do
    it "returns true for the same class and same url" do
      expect(described_class.new("/file")).to eq described_class.new("/file")
    end

    it "returns false for the same class and different url" do
      expect(described_class.new("/file"))
        .not_to eq described_class.new("/different")
    end

    it "returns false for a different class" do
      other = Openapi3Parser::SourceInput::Raw.new({})
      expect(described_class.new("/file")).not_to eq other
    end
  end

  describe "#relative_to" do
    it "returns a string representing the relative path difference" do
      instance = described_class.new("/path/to/file.yaml")
      other = described_class.new("/file.yaml")
      expect(instance.relative_to(other)).to eq "path/to/file.yaml"
    end

    it "represents a lower directory with .." do
      instance = described_class.new("/path/file.yaml")
      other = described_class.new("/path/to/file.yaml")
      expect(instance.relative_to(other)).to eq "../file.yaml"
    end

    it "returns the absolute path when there isn't a relation in common" do
      instance = described_class.new("/root/file.yaml")
      other = described_class.new("/user/file.yaml")

      expect(instance.relative_to(other)).to eq "/root/file.yaml"
    end

    it "returns the full path when compared to a URL input" do
      instance = described_class.new("/path/to/file.yaml")
      url = "https://example.org/file"
      stub_request(:get, url)
      other = Openapi3Parser::SourceInput::Url.new(url)
      expect(instance.relative_to(other)).to eq "/path/to/file.yaml"
    end

    context "when compared to a raw input" do
      it "compares relative to the working directory if one exists" do
        instance = described_class.new("/path/to/file.yaml")
        other = Openapi3Parser::SourceInput::Raw.new(
          {},
          working_directory: "/path/other"
        )
        expect(instance.relative_to(other)).to eq "../to/file.yaml"
      end

      it "returns the original path if there isn't a working directory" do
        instance = described_class.new("/path/to/file.yaml")
        other = Openapi3Parser::SourceInput::Raw.new({})
        expect(instance.relative_to(other)).to eq "/path/to/file.yaml"
      end
    end
  end
end
