# frozen_string_literal: true

require "openapi3_parser/context/pointer"

RSpec.describe Openapi3Parser::Context::Pointer do
  describe ".fragment" do
    subject { described_class.new(segments).fragment }

    context "when segments are empty" do
      let(:segments) { [] }
      it { is_expected.to eq "#/" }
    end

    context "when segments are populated" do
      let(:segments) { %w[openapi info title] }
      it { is_expected.to eq "#/openapi/info/title" }
    end

    context "when segments contain characters not suitable for URLS" do
      let(:segments) { ["with/slash", "with space"] }
      it { is_expected.to eq "#/with%2Fslash/with%20space" }
    end
  end
end
