# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Url do
  describe ".call" do
    it "returns nil for a valid URL" do
      expect(described_class.call("https://example.org/resource"))
        .to be_nil
    end

    it "returns an error for an invalid URL" do
      expect(described_class.call("not a URL"))
        .to eq %("not a URL" is not a valid URL)
    end
  end
end
