# frozen_string_literal: true

require "openapi3_parser/document"
require "openapi3_parser/node/openapi"
require "openapi3_parser/source"
require "openapi3_parser/source_input/raw"
require "openapi3_parser/source_input/file"
require "openapi3_parser/validation/error_collection"

RSpec.describe Openapi3Parser::Document do
  let(:source_input) { Openapi3Parser::SourceInput::Raw.new(source_data) }

  let(:source_data) do
    {
      "openapi" => "3.0.0",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {},
      "components" => components_data
    }
  end

  let(:components_data) do
    {
      "responses" => {
        "a-response" => { "$ref" => "test.json" }
      }
    }
  end

  let(:responses_data) do
    {
      "description" => "Test"
    }
  end

  before { allow(File).to receive(:read).and_return(responses_data.to_json) }

  describe "#root" do
    subject { described_class.new(source_input).root }
    it { is_expected.to be_an_instance_of(Openapi3Parser::Node::Openapi) }
  end

  describe "#source_for_source_input" do
    subject do
      described_class.new(source_input)
                     .source_for_source_input(other)
    end

    context "when the source input is known" do
      let(:other) { source_input }
      it { is_expected.to be_an_instance_of(Openapi3Parser::Source) }
    end

    context "when the source input is not known" do
      let(:other) { Openapi3Parser::SourceInput::Raw.new({}) }
      it { is_expected.to be_nil }
    end
  end

  describe "#reference_sources" do
    subject(:reference_sources) do
      described_class.new(source_input).reference_sources
    end

    context "when there are no references" do
      let(:components_data) { {} }
      it { is_expected.to be_empty }
    end

    context "when there is a reference" do
      it "contains a source" do
        source = an_instance_of(Openapi3Parser::Source)
        expect(reference_sources).to match_array(source)
      end

      it "has source with expected source input" do
        source_input = Openapi3Parser::SourceInput::File.new("test.json")
        expect(reference_sources[0].source_input).to eq source_input
      end
    end
  end

  describe "#errors" do
    subject(:errors) do
      described_class.new(source_input).errors
    end

    let(:error_collection_class) { Openapi3Parser::Validation::ErrorCollection }

    it { is_expected.to be_an_instance_of(error_collection_class) }

    context "when there are no errors" do
      it { is_expected.to be_empty }
    end

    context "when there are errors" do
      let(:source_data) { {} }
      it { is_expected.not_to be_empty }
    end
  end
end
