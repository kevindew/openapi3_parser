# frozen_string_literal: true

require "openapi3_parser/context/pointer"

RSpec.describe Openapi3Parser::Context::Pointer do
  describe ".from_fragment" do
    subject { described_class.from_fragment(fragment) }

    context "when fragment is at a root" do
      let(:fragment) { "#/test" }
      it { is_expected.to eq described_class.new(%w[test]) }
    end

    context "when fragment is not at a root" do
      let(:fragment) { "#test" }
      it { is_expected.to eq described_class.new(%w[test], false) }
    end

    context "when fragment misses the hash" do
      let(:fragment) { "/test" }
      it { is_expected.to eq described_class.new(%w[test], true) }
    end

    context "when fragment contains integers" do
      let(:fragment) { "#/test/1/hi" }
      it { is_expected.to eq described_class.new(["test", 1, "hi"]) }
    end

    context "when fragment contains escaped characters" do
      let(:fragment) { "#/test%20this/and%2Fthat" }
      it { is_expected.to eq described_class.new(["test this", "and/that"]) }
    end
  end

  describe "#fragment" do
    subject { described_class.new(segments, root).fragment }
    let(:root) { true }

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

    context "when segments contain numbers" do
      let(:segments) { [0, 0.123] }
      it { is_expected.to eq "#/0/0.123" }
    end

    context "when root is false" do
      let(:root) { false }
      let(:segments) { %w[openapi info title] }
      it { is_expected.to eq "#openapi/info/title" }
    end
  end
end
