# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Email do
  describe ".call" do
    it "returns a message when an email is invalid" do
      expect(described_class.call("not an email"))
        .to eq %("not an email" is not a valid email address)
    end

    it "returns nil for a valid email" do
      expect(described_class.call("kevin@example.com")).to be_nil
    end
  end
end
