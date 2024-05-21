# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::Pointer do
  describe ".from_fragment" do
    it "creates a pointer object based on the fragment" do
      expect(described_class.from_fragment("#/test"))
        .to eq described_class.new(%w[test])
    end

    it "creates a relative pointer when the fragment isn't an absolute path" do
      expect(described_class.from_fragment("#test"))
        .to eq described_class.new(%w[test], absolute: false)
    end

    it "copes if a pointer is missing the hash character" do
      expect(described_class.from_fragment("/test"))
        .to eq described_class.new(%w[test])
    end

    it "converts numeric segments to integers" do
      expect(described_class.from_fragment("#/test/1/hi"))
        .to eq described_class.new(["test", 1, "hi"])
    end

    it "resolves any URI escaping" do
      expect(described_class.from_fragment("#/test%20this/and%2Fthat"))
        .to eq described_class.new(["test this", "and/that"])
    end

    it "copes with an encoded ~ in a pointer" do
      expect(described_class.from_fragment("#/test~0this"))
        .to eq described_class.new(["test~this"])
    end

    it "copes with an encoded / in a pointer" do
      expect(described_class.from_fragment("#/test~1this"))
        .to eq described_class.new(["test/this"])
    end

    it "copes with an encoded ~1 in a pointer" do
      expect(described_class.from_fragment("#/test~01this"))
        .to eq described_class.new(["test~1this"])
    end
  end

  describe ".merge_pointers" do
    it "adapts a pointer based on a new one that is relative" do
      merged_pointer = described_class.merge_pointers(
        described_class.new(%w[test]),
        described_class.new(%w[new], absolute: false)
      )

      expect(merged_pointer).to eq described_class.new(%w[test new])
    end

    it "replaces a pointer if the new one is absolute" do
      new_pointer = described_class.new(%w[new])
      merged_pointer = described_class.merge_pointers(
        described_class.new(%w[test]),
        new_pointer
      )

      expect(merged_pointer).to eq new_pointer
    end

    it "can accept array pointers" do
      merged_pointer = described_class.merge_pointers(%w[test path], %w[further along])
      expect(merged_pointer).to eq described_class.new(%w[test path further along])
    end

    it "can accept string fragments as pointers" do
      merged_pointer = described_class.merge_pointers("#path/to/item", "#../../new")
      expect(merged_pointer).to eq described_class.new(%w[path new])
    end

    it "copes when passed nil pointers" do
      pointer = described_class.new(%w[a])

      expect(described_class.merge_pointers(pointer, nil)).to eq pointer
      expect(described_class.merge_pointers(nil, pointer)).to eq pointer
      expect(described_class.merge_pointers(nil, nil)).to be_nil
    end
  end

  describe "#fragment" do
    it "returns the pointer as a fragment" do
      instance = described_class.new(%w[openapi info title])
      expect(instance.fragment).to eq "#/openapi/info/title"
    end

    it "can return a relative fragment" do
      instance = described_class.new(%w[info title], absolute: false)
      expect(instance.fragment).to eq "#info/title"
    end

    it "URI encodes characters that not suitable for URLs" do
      instance = described_class.new(["with space"])
      expect(instance.fragment).to eq "#/with%20space"
    end

    it "encodes JSON pointer special characters" do
      instance = described_class.new(["with/slash", "with~tilde", "with~1tilde"])
      expect(instance.fragment).to eq "#/with~1slash/with~0tilde/with~01tilde"
    end

    it "copes with segments that are numbers" do
      instance = described_class.new([0, 0.123])
      expect(instance.fragment).to eq "#/0/0.123"
    end

    it "returns an empty fragment when segments are empty" do
      absolute = described_class.new([])
      expect(absolute.fragment).to eq "#/"

      relative = described_class.new([], absolute: false)
      expect(relative.fragment).to eq "#"
    end
  end
end
