# frozen_string_literal: true

RSpec.describe Openapi3Parser::Source::Reference do
  describe ".only_fragment?" do
    subject { described_class.new(reference).only_fragment? }

    context "when reference is only a fragment" do
      let(:reference) { "#/test" }

      it { is_expected.to be true }
    end

    context "when reference includes a filename" do
      let(:reference) { "test.yaml" }

      it { is_expected.to be false }
    end
  end

  describe ".fragment" do
    subject { described_class.new(reference).fragment }

    context "when reference has a fragment" do
      let(:reference) { "test.yaml#/test" }

      it { is_expected.to eq "/test" }
    end

    context "when reference hasn't got a reference" do
      let(:reference) { "test.yaml" }

      it { is_expected.to be_nil }
    end
  end

  describe ".resource_uri" do
    subject { described_class.new(reference).resource_uri }

    context "when reference has a fragment" do
      let(:reference) { "test.yaml#/test" }

      it { is_expected.to eq URI.parse("test.yaml") }
    end

    context "when reference is only a fragment" do
      let(:reference) { "#/test" }

      it { is_expected.to eq URI.parse("") }
    end
  end

  describe ".absolute?" do
    subject { described_class.new(reference).absolute? }

    context "when reference is an absolute URL" do
      let(:reference) { "http://example.com/" }

      it { is_expected.to be true }
    end

    context "when reference is to a relative file" do
      let(:reference) { "test.yaml" }

      it { is_expected.to be false }
    end

    context "when reference is to a file in root of file system" do
      let(:reference) { "/path/to/file" }

      it { is_expected.to be false }
    end
  end

  describe ".json_pointer" do
    subject { described_class.new(reference).json_pointer }

    context "when reference is not a fragment" do
      let(:reference) { "test.yaml" }

      it { is_expected.to be_empty }
    end

    context "when reference has a fragment" do
      let(:reference) { "test.yaml#/basic" }

      it { is_expected.to match(%w[basic]) }
    end

    context "when reference is URL encoded" do
      let(:reference) { "test.yaml#/two%20words/comma%2C%20seperated" }

      it { is_expected.to match(["two words", "comma, seperated"]) }
    end
  end
end
