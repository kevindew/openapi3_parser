# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::Reference do
  describe ".only_fragment?" do
    it "returns true when reference is only a fragment" do
      expect(described_class.new("#/test").only_fragment?).to be true
    end

    it "returns false when reference includes a filename" do
      expect(described_class.new("test.yaml").only_fragment?).to be false
    end
  end

  describe ".fragment" do
    it "returns the fragment for a reference with a fragment" do
      expect(described_class.new("test.yaml#/test").fragment).to eq "/test"
    end

    it "returns nil for a reference without a fragment" do
      expect(described_class.new("test.yaml").fragment).to be_nil
    end
  end

  describe ".resource_uri" do
    it "returns a URI object for the non fragment portion of the reference" do
      expect(described_class.new("test.yaml#/test").resource_uri)
        .to eq URI.parse("test.yaml")
    end

    it "returns an empty URI object when the reference is only a fragment" do
      expect(described_class.new("#/test").resource_uri)
        .to eq URI.parse("")
    end
  end

  describe ".absolute?" do
    it "returns true when reference is an absolute URL" do
      expect(described_class.new("https://example.org").absolute?).to be true
    end

    it "returns false when reference is a relative URL" do
      expect(described_class.new("test.yaml").absolute?).to be false
    end

    it "returns false when reference is to a root file in a file system" do
      expect(described_class.new("/path/to/file.yaml").absolute?).to be false
    end
  end

  describe ".json_pointer" do
    it "returns an array of reference segments" do
      expect(described_class.new("test.yaml#/path/to/field").json_pointer)
        .to eq %w[path to field]
    end

    it "decodes URL encoded segments" do
      instance = described_class.new("test.yaml#/two%20words/comma%2C%20seperated")
      expect(instance.json_pointer).to eq ["two words", "comma, seperated"]
    end

    it "returns an empty array for a reference without a fragment" do
      expect(described_class.new("test.yaml").json_pointer).to eq []
    end
  end
end
