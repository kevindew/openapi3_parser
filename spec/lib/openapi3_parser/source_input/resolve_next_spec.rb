# frozen_string_literal: true

require "openapi3_parser/source_input/resolve_next"
require "openapi3_parser/source_input/file"
require "openapi3_parser/source_input/raw"
require "openapi3_parser/source_input/url"
require "openapi3_parser/source/reference"

RSpec.describe Openapi3Parser::SourceInput::ResolveNext do
  describe "#call" do
    subject do
      described_class.call(reference,
                           current_source_input,
                           base_url: base_url,
                           working_directory: working_directory)
    end
    before do
      allow(File).to receive(:read).and_return("")
      stub_request(:get, %r{^https://example.com/})
    end

    let(:reference) do
      Openapi3Parser::Source::Reference.new(literal_reference)
    end
    let(:current_source_input) do
      Openapi3Parser::SourceInput::Raw.new({},
                                           base_url: base_url,
                                           working_directory: working_directory)
    end
    let(:base_url) { nil }
    let(:working_directory) { nil }

    context "when reference is a fragment" do
      let(:literal_reference) { "#/test" }
      it { is_expected.to be current_source_input }
    end

    context "when reference is a relative file" do
      let(:literal_reference) { "test.yaml#/test" }
      context "and base_url and working_directory aren't set" do
        let(:file_source_input) do
          path = File.expand_path("test.yaml", Dir.pwd)
          Openapi3Parser::SourceInput::File.new(path)
        end
        it { is_expected.to eq file_source_input }
      end

      context "and base_url is set" do
        let(:base_url) { "https://example.com/" }
        let(:url_source_input) do
          Openapi3Parser::SourceInput::Url.new("https://example.com/test.yaml")
        end
        it { is_expected.to eq url_source_input }
      end

      context "and working_directory is set" do
        let(:working_directory) { "/test/path" }
        let(:file_source_input) do
          Openapi3Parser::SourceInput::File.new("/test/path/test.yaml")
        end
        it { is_expected.to eq file_source_input }
      end
    end

    context "when reference is an absolute URL" do
      let(:literal_reference) { "https://example.com/test.yaml#/test" }
      let(:url_source_input) do
        Openapi3Parser::SourceInput::Url.new("https://example.com/test.yaml")
      end
      it { is_expected.to eq url_source_input }
    end

    context "when reference is a path prefixed with a slash" do
      let(:literal_reference) { "/path/test.yaml#/test" }
      let(:file_source_input) do
        Openapi3Parser::SourceInput::File.new("/path/test.yaml")
      end
      it { is_expected.to eq file_source_input }

      context "and a base_url is set" do
        let(:base_url) { "https://example.com/different/path" }
        let(:url_source_input) do
          Openapi3Parser::SourceInput::Url.new(
            "https://example.com/path/test.yaml"
          )
        end
        it { is_expected.to eq url_source_input }
      end
    end
  end
end
