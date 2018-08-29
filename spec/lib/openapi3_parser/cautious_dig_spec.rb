# frozen_string_literal: true

RSpec.describe Openapi3Parser::CautiousDig do
  describe ".call" do
    subject { described_class.call(collection, *segments) }

    context "when the segment doesn't exist" do
      let(:collection) { { "test" => "value" } }
      let(:segments) { %w[not_test] }

      it { is_expected.to be_nil }
    end

    context "when a segment does exist" do
      let(:collection) { { "test" => ["value"] } }
      let(:segments) { ["test", 0] }

      it { is_expected.to be "value" }
    end

    context "when hash keys aren't strings but segments are" do
      let(:collection) { { symbol: "value" } }
      let(:segments) { %w[symbol] }

      it { is_expected.to be "value" }
    end

    context "when array key is passed as a string" do
      let(:collection) { %w[zero one two] }
      let(:segments) { %w[1] }

      it { is_expected.to be "one" }
    end
  end
end
