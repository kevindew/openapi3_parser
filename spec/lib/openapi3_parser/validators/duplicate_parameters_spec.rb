# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::DuplicateParameters do
  describe ".call" do
    subject { described_class.call(parameters) }

    context "when input has no duplicates" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "path" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.to be_nil }
    end

    context "when input has duplicates" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "path" },
          { "name" => "id", "in" => "path" }
        ]
      end

      it { is_expected.to eq "Duplicate parameters: id in path" }
    end

    context "when there are multiple duplicates" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "path" },
          { "name" => "id", "in" => "path" },
          { "name" => "address", "in" => "query" },
          { "name" => "address", "in" => "query" }
        ]
      end

      it do
        expect(subject).to eq "Duplicate parameters: id in path, address in query"
      end
    end

    context "when parameters are in the wrong type" do
      let(:parameters) { [1, "string", [1, 2, 3], {}] }

      it { is_expected.to be_nil }
    end
  end
end
