# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::Pointer do
  describe ".from_fragment" do
    subject { described_class.from_fragment(fragment) }

    context "when fragment is at absolute" do
      let(:fragment) { "#/test" }
      it { is_expected.to eq described_class.new(%w[test]) }
    end

    context "when fragment is not at absolute" do
      let(:fragment) { "#test" }
      it { is_expected.to eq described_class.new(%w[test], absolute: false) }
    end

    context "when fragment misses the hash" do
      let(:fragment) { "/test" }
      it { is_expected.to eq described_class.new(%w[test], absolute: true) }
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

  describe ".merge_pointers" do
    subject { described_class.merge_pointers(base_pointer, new_pointer) }

    context "when both pointers are nil" do
      let(:base_pointer) { nil }
      let(:new_pointer) { nil }
      it { is_expected.to be_nil }
    end

    context "when base_pointer is nil" do
      let(:base_pointer) { nil }
      let(:new_pointer) { described_class.new(%w[test]) }
      it { is_expected.to eq new_pointer }
    end

    context "when new_pointer is nil" do
      let(:base_pointer) { described_class.new(%w[test]) }
      let(:new_pointer) { nil }
      it { is_expected.to eq base_pointer }
    end

    context "when new_pointer is absolute" do
      let(:base_pointer) { described_class.new(%w[test]) }
      let(:new_pointer) { described_class.new(%w[new]) }
      it { is_expected.to eq new_pointer }
    end

    context "when new_pointer is not absolute" do
      let(:base_pointer) { described_class.new(%w[test]) }
      let(:new_pointer) { described_class.new(%w[new], absolute: false) }
      it { is_expected.to eq described_class.new(%w[test new]) }
    end

    context "when pointers are arrays" do
      let(:base_pointer) { %w[test path] }
      let(:new_pointer) { %w[further along] }
      it { is_expected.to eq described_class.new(%w[test path further along]) }
    end

    context "when pointers are fragments" do
      let(:base_pointer) { "#path" }
      let(:new_pointer) { "#to" }
      it { is_expected.to eq described_class.new(%w[path to]) }
    end

    context "when pointers are fragments with relative mapping" do
      let(:base_pointer) { "#path/to/item" }
      let(:new_pointer) { "#../../me" }
      it { is_expected.to eq described_class.new(%w[path me]) }
    end
  end

  describe "#fragment" do
    subject { described_class.new(segments, absolute: absolute).fragment }
    let(:absolute) { true }

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

    context "when absolute is false" do
      let(:absolute) { false }
      let(:segments) { %w[openapi info title] }
      it { is_expected.to eq "#openapi/info/title" }
    end
  end
end
