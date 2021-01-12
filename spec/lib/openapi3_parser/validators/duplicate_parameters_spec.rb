# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::DuplicateParameters do
  describe ".call" do
    it "returns nil when there aren't any duplicate parameters" do
      parameters = [
        { "name" => "id", "in" => "path" },
        { "name" => "id", "in" => "query" }
      ]

      expect(described_class.call(parameters)).to be_nil
    end

    it "copes with parameters that are in an unexpected type" do
      parameters = [1, "string", [1, 2, 3], {}]
      expect(described_class.call(parameters)).to be_nil
    end

    it "returns an error for dupliate parameters" do
      parameters = [
        { "name" => "id", "in" => "path" },
        { "name" => "id", "in" => "path" },
        { "name" => "field", "in" => "path" },
        { "name" => "field", "in" => "path" },
        { "name" => "address", "in" => "query" },
        { "name" => "address", "in" => "query" }
      ]

      expect(described_class.call(parameters))
        .to eq "Duplicate parameters: id in path, field in path, address in query"
    end
  end
end
