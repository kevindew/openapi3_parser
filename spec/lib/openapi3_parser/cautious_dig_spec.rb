# frozen_string_literal: true

RSpec.describe Openapi3Parser::CautiousDig do
  describe ".call" do
    it "retuns the value when passed an existent segment" do
      expect(described_class.call({ "test" => ["value"] }, "test", 0))
        .to be("value")
    end

    it "retuns nil when passed a non-existent segment" do
      expect(described_class.call({ "test" => ["value"] }, "not_test", 0))
        .to be_nil
    end

    it "resolves symbol hash keys when passed a string" do
      expect(described_class.call({ symbol: "value" }, "symbol"))
        .to be("value")
    end

    it "resolves an array key when passed as a string" do
      expect(described_class.call(%w[zero one two], "1"))
        .to be("one")
    end
  end
end
