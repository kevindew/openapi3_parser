# frozen_string_literal: true

require "openapi3_parser/source_input/file"
require "openapi3_parser/source_input/raw"
require "openapi3_parser/source_input/url"
require "openapi3_parser/error"
require "openapi3_parser/source/reference"

RSpec.describe Openapi3Parser::SourceInput::File do
  let(:valid_input) { "test: this" }
  let(:unparsable_input) { "*invalid: yaml" }
  let(:inaccessible_input_error) { Openapi3Parser::Error::InaccessibleInput }
  let(:unparsable_input_error) { Openapi3Parser::Error::UnparsableInput }
  let(:path) { "/path/to/openapi.yaml" }

  before { allow(File).to receive(:read).and_return(valid_input) }

  describe ".available?" do
    subject { described_class.new(path).available? }

    context "when input is valid" do
      it { is_expected.to be true }
    end

    context "when file can't be opened" do
      before { allow(File).to receive(:read).and_raise(Errno::ENOENT) }
      it { is_expected.to be false }
    end

    context "when file can't be parsed" do
      before { allow(File).to receive(:read).and_return(unparsable_input) }
      it { is_expected.to be false }
    end
  end

  describe ".access_error" do
    subject { described_class.new(path).access_error }

    context "when input is valid" do
      it { is_expected.to be_nil }
    end

    context "when input can't be opened" do
      before { allow(File).to receive(:read).and_raise(Errno::ENOENT) }
      it { is_expected.to be_a_kind_of(inaccessible_input_error) }
    end
  end

  describe ".parse_error" do
    subject { described_class.new(path).parse_error }

    context "when input is valid" do
      it { is_expected.to be_nil }
    end

    context "when input is unparsable" do
      before { allow(File).to receive(:read).and_return(unparsable_input) }
      it { is_expected.to be_a_kind_of(unparsable_input_error) }
    end
  end

  describe ".contents" do
    subject { described_class.new(path).contents }

    context "when input is valid" do
      let(:valid_input) { "key: value" }
      it { is_expected.to match("key" => "value") }
    end

    context "when input can't be opened" do
      before { allow(File).to receive(:read).and_raise(Errno::ENOENT) }
      it "raises a InaccessibleInput error" do
        expect { subject }.to raise_error(inaccessible_input_error)
      end
    end

    context "when input is unparsable" do
      before { allow(File).to receive(:read).and_return(unparsable_input) }
      it "raises a UnparsableInput error" do
        expect { subject }.to raise_error(unparsable_input_error)
      end
    end
  end

  describe ".resolve_next" do
    subject { described_class.new(path).resolve_next(reference) }

    let(:path) { "/path/to/file.yaml" }
    let(:next_path) { "../new-file.yaml#/object" }
    let(:reference) { Openapi3Parser::Source::Reference.new(next_path) }
    let(:source_input) { described_class.new("/path/new-file.yaml") }

    it { is_expected.to eq source_input }
  end

  describe ".==" do
    subject { described_class.new(path).==(other) }

    context "when path is the same" do
      let(:other) { described_class.new(path) }
      it { is_expected.to be true }
    end

    context "when path is different" do
      let(:other) { described_class.new("/different") }
      it { is_expected.to be false }
    end

    context "when class is different" do
      let(:other) { Openapi3Parser::SourceInput::Raw.new({}) }
      it { is_expected.to be false }
    end
  end

  describe ".relative_to" do
    subject { described_class.new(path).relative_to(other) }
    let(:path) { "/path/to/file.yaml" }
    let(:other) { described_class.new("/path/to/file.yaml") }

    it { is_expected.to eq "file.yaml" }

    context "when path is up a directory" do
      let(:path) { "/path/to/other/file.yaml" }
      it { is_expected.to eq "other/file.yaml" }
    end

    context "when path is down a directory" do
      let(:path) { "/path/to-file.yaml" }
      it { is_expected.to eq "../to-file.yaml" }
    end

    context "when other is a raw input in same working directory" do
      let(:other) do
        Openapi3Parser::SourceInput::Raw.new({}, working_directory: "/path/to")
      end
      it { is_expected.to eq "file.yaml" }
    end

    context "when other is a raw input in a different working directory" do
      let(:other) do
        Openapi3Parser::SourceInput::Raw.new({}, working_directory: "/tmp/test")
      end
      it { is_expected.to eq path }
    end

    context "when other is a url input" do
      let(:url) { "http://example.com/test.yaml" }
      let(:other) { Openapi3Parser::SourceInput::Url.new(url) }
      before { stub_request(:get, url) }

      it { is_expected.to eq path }
    end
  end
end
