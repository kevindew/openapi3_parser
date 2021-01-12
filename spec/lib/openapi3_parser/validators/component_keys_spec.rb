# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::ComponentKeys do
  describe ".call" do
    it "returns nil for a hash with a valid component key" do
      expect(described_class.call({ "valid.key" => {} }))
        .to be_nil
    end

    it "returns an error for a hash with an invalid component key" do
      expect(described_class.call({ "Invalid Key" => {} }))
        .to eq "Contains invalid keys: Invalid Key"
    end
  end
end
