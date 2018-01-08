# frozen_string_literal: true

require "openapi3_parser/source_input/raw"
require "openapi3_parser/source_input/url"
require "openapi3_parser/error"
require "openapi3_parser/source/reference"

RSpec.describe Openapi3Parser::SourceInput::Raw do
  let(:valid_input) { {} }
  let(:unparsable_input) { "*invalid: yaml" }
  let(:unparsable_input_error) { Openapi3Parser::Error::UnparsableInput }

  describe ".available?" do
    subject { described_class.new(input).available? }

    context "when input is valid" do
      let(:input) { valid_input }
      it { is_expected.to be true }
    end

    context "when input is unparsable" do
      let(:input) { unparsable_input }
      it { is_expected.to be false }
    end
  end

  describe ".parse_error" do
    subject { described_class.new(input).parse_error }

    context "when input is valid" do
      let(:input) { valid_input }
      it { is_expected.to be_nil }
    end

    context "when input is unparsable" do
      let(:input) { unparsable_input }
      it { is_expected.to be_a_kind_of(unparsable_input_error) }
    end
  end

  describe ".contents" do
    subject { described_class.new(input).contents }

    context "when input is valid" do
      let(:input) { valid_input }
      it { is_expected.to match(valid_input) }
    end

    context "when input is unparsable" do
      let(:input) { unparsable_input }
      it "raises a UnparsableInput error" do
        expect { subject }.to raise_error(unparsable_input_error)
      end
    end
  end

  describe ".resolve_next" do
    before { stub_request(:get, %r{^https://example.com/}) }
    subject { described_class.new(valid_input).resolve_next(reference) }
    let(:url) { "https://example.com/openapi" }

    let(:reference) { Openapi3Parser::Source::Reference.new(url) }
    let(:url_source_input) { Openapi3Parser::SourceInput::Url.new(url) }

    it { is_expected.to eq url_source_input }
  end

  describe ".==" do
    subject { described_class.new(valid_input).==(other) }

    context "when input is the same" do
      let(:other) { described_class.new(valid_input) }
      it { is_expected.to be true }
    end

    context "when input is different" do
      let(:other) { described_class.new(unparsable_input) }
      it { is_expected.to be false }
    end

    context "when class is different" do
      let(:other) { Openapi3Parser::SourceInput::File.new("test.yml") }
      it { is_expected.to be false }
    end
  end
end
