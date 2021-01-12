# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::AbsoluteUri do
  describe ".call" do
    it "returns nil for a valid URI" do
      expect(described_class.call("http://example.com/test?query=blah#anchor"))
        .to be_nil
    end

    it "returns an error for a relative url" do
      expect(described_class.call("test?query=blah#anchor"))
        .to eq %("test?query=blah#anchor" is not a absolute URI)
    end

    it "returns an error for an invalid URI" do
      expect(described_class.call("not a URI"))
        .to eq %("not a URI" is not a valid URI)
    end
  end
end
