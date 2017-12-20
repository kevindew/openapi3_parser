# frozen_string_literal: true

require "openapi3_parser/source_input/url"
require "openapi3_parser/error"
require "openapi3_parser/source/reference"

RSpec.describe Openapi3Parser::SourceInput::Url do
  let(:valid_input) { "test: this" }
  let(:unparsable_input) { "*invalid: yaml" }
  let(:inaccessible_input_error) { Openapi3Parser::Error::InaccessibleInput }
  let(:unparsable_input_error) { Openapi3Parser::Error::UnparsableInput }
  let(:url) { "https://example.com/openapi.yaml" }

  def stub_200_request(body)
    stub_request(:get, %r{^https://example.com})
      .to_return(body: body, status: 200)
  end

  def stub_404_request
    stub_request(:get, %r{^https://example.com})
      .to_return(status: 404)
  end

  before { stub_200_request(valid_input) }

  describe ".available?" do
    subject { described_class.new(url).available? }

    context "when input is valid" do
      it { is_expected.to be true }
    end

    context "when file can't be opened" do
      before { stub_404_request }
      it { is_expected.to be false }
    end

    context "when file can't be parsed" do
      before { stub_200_request(unparsable_input) }
      it { is_expected.to be false }
    end
  end

  describe ".access_error" do
    subject { described_class.new(url).access_error }

    context "when input is valid" do
      it { is_expected.to be_nil }
    end

    context "when input can't be opened" do
      before { stub_404_request }
      it { is_expected.to be_a_kind_of(inaccessible_input_error) }
    end
  end

  describe ".parse_error" do
    subject { described_class.new(url).parse_error }

    context "when input is valid" do
      it { is_expected.to be_nil }
    end

    context "when input is unparsable" do
      before { stub_200_request(unparsable_input) }
      it { is_expected.to be_a_kind_of(unparsable_input_error) }
    end
  end

  describe ".contents" do
    subject { described_class.new(url).contents }

    context "when input is valid" do
      before { stub_200_request(valid_input) }
      let(:valid_input) { "key: value" }
      it { is_expected.to match("key" => "value") }
    end

    context "when input can't be opened" do
      before { stub_404_request }
      it "raises a InaccessibleInput error" do
        expect { subject }.to raise_error(inaccessible_input_error)
      end
    end

    context "when input is unparsable" do
      before { stub_200_request(unparsable_input) }
      it "raises a UnparsableInput error" do
        expect { subject }.to raise_error(unparsable_input_error)
      end
    end
  end

  describe ".resolve_next" do
    subject { described_class.new(url).resolve_next(reference) }

    let(:url) { "https://example.com/path/to/file.yaml" }
    let(:relative_url) { "../new-file.yaml#/object" }
    let(:reference) { Openapi3Parser::Source::Reference.new(relative_url) }
    let(:source_input) do
      described_class.new("https://example.com/path/new-file.yaml")
    end

    it { is_expected.to eq source_input }
  end

  describe ".==" do
    subject { described_class.new(url).==(other) }

    context "when url is the same" do
      let(:other) { described_class.new(url) }
      it { is_expected.to be true }
    end

    context "when url is different" do
      let(:other) { described_class.new("https://example.com/different") }
      it { is_expected.to be false }
    end
  end
end
