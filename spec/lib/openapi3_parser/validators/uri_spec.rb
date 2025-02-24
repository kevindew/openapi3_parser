# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Uri do
  describe ".call" do
    it "returns nil for a valid URI" do
      expect(described_class.call("https://example.org/resource"))
        .to be_nil
    end

    it "returns an error for an invalid URI" do
      expect(described_class.call("not a URI"))
        .to eq %("not a URI" is not a valid URI)
    end
  end
end
