# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Reference do
  describe "#errors" do
    it "returns an empty array when input is valid" do
      expect(described_class.new("#/test").errors).to match_array([])
    end

    it "has an error when input is not a string" do
      expect(described_class.new(12).errors)
        .to match_array(["Expected a string"])
    end

    it "has an error when input is an invalid URI" do
      expect(described_class.new("not a uri").errors)
        .to match_array(["Could not parse as a URI"])
    end

    it "has an error when input is an invalid JSON pointer" do
      expect(described_class.new("./test#any-old-fragment").errors)
        .to match_array(["Invalid JSON pointer, expected a root slash"])
    end
  end

  describe "#valid?" do
    it "returns true for valid input" do
      expect(described_class.new("#/test")).to be_valid
    end

    it "returns false for invalid input" do
      expect(described_class.new(12)).not_to be_valid
    end
  end
end
