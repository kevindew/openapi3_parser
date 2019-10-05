# frozen_string_literal: true

RSpec.describe Openapi3Parser::Document do
  let(:source_input) { Openapi3Parser::SourceInput::Raw.new(source_data) }

  let(:source_data) do
    {
      "openapi" => openapi_version,
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {},
      "components" => components_data
    }
  end

  let(:openapi_version) { "3.0.0" }

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

  describe ".new" do
    let(:instance) { described_class.new(source_input) }

    context "when an allowed version is included" do
      let(:openapi_version) { "3.0.1" }

      it "it does not have warnings" do
        expect(instance.warnings).to be_empty
      end
    end

    context "when no version is include in the source data" do
      let(:openapi_version) { nil }

      it "raises a warning" do
        expect(instance.warnings.first).to match(/Unspecified OpenAPI version/)
      end
    end

    context "when an unsupported version is include in the source data" do
      let(:openapi_version) { "2.0.0" }

      it "raises a warning" do
        expect(instance.warnings.first).to match(
          /Unsupported OpenAPI version #{Regexp.escape('(2.0.0)')}/
        )
      end
    end
  end

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
        expect(reference_sources)
          .to match_array(an_instance_of(Openapi3Parser::Source))
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

    context "when there are reference errors" do
      let(:components_data) do
        {
          "responses" => {
            "invalid" => {},
            "invalid-internal-reference" => { "$ref" => "#/invalid" },
            "invalid-external-reference" => { "$ref" => "test.json#/invalid" }
          }
        }
      end

      let(:responses_data) do
        {
          "invalid" => {}
        }
      end

      # we're vulnerable to get duplicates of references in the root file
      # since they can be validated as part of reference registry and
      # root document.
      it "returns each error without duplicates" do
        errors = {
          "#/components/responses/invalid" =>
            ["Missing required fields: description"],
          "#/components/responses/invalid-internal-reference/%24ref" =>
            ["#/invalid is not defined"],
          "#/components/responses/invalid-external-reference/%24ref" =>
            ["test.json#/invalid does not resolve to a valid object"],
          "test.json#/invalid" =>
            ["Missing required fields: description"]
        }
        expect(errors.to_h).to eq errors
      end
    end
  end

  describe "#openapi_version" do
    subject { described_class.new(source_input).openapi_version }

    context "when an allowed version is used" do
      let(:openapi_version) { "3.0.1" }

      it { is_expected.to eq("3.0") }
    end

    context "when no version is provided" do
      let(:openapi_version) { nil }

      it { is_expected.to eq(described_class::DEFAULT_OPENAPI_VERSION) }
    end

    context "when an unsupported version is provided" do
      let(:openapi_version) { "2.0.0" }

      it { is_expected.to eq(described_class::DEFAULT_OPENAPI_VERSION) }
    end
  end

  describe "#node_at" do
    subject { described_class.new(source_input).node_at(pointer, relative_to) }
    let(:relative_to) { nil }

    context "when a fragment is provided" do
      let(:pointer) { "#/info" }

      it { is_expected.to be_an_instance_of(Openapi3Parser::Node::Info) }
    end

    context "when an array is provided" do
      let(:pointer) { %w[info] }

      it { is_expected.to be_an_instance_of(Openapi3Parser::Node::Info) }
    end

    context "when a pointer is provided" do
      let(:pointer) { Openapi3Parser::Source::Pointer.new(%w[info]) }

      it { is_expected.to be_an_instance_of(Openapi3Parser::Node::Info) }
    end

    context "when field doesn't exist" do
      let(:pointer) { "#/blahblah" }

      it { is_expected.to be_nil }
    end

    context "when pointer is relative_to a different pointer" do
      let(:pointer) { "#../" }
      let(:relative_to) { "#/info/title" }

      it { is_expected.to be_an_instance_of(Openapi3Parser::Node::Info) }
    end
  end

  describe "#resolved_input_at" do
    subject do
      described_class.new(source_input).resolved_input_at(pointer, relative_to)
    end
    let(:relative_to) { nil }

    context "when a fragment is provided" do
      let(:pointer) { "#/info/version" }

      it { is_expected.to eq "1.0.0" }
    end

    context "when an array is provided" do
      let(:pointer) { %w[info version] }

      it { is_expected.to eq "1.0.0" }
    end

    context "when a pointer is provided" do
      let(:pointer) { Openapi3Parser::Source::Pointer.new(%w[info version]) }

      it { is_expected.to eq "1.0.0" }
    end

    context "when field doesn't exist" do
      let(:pointer) { "#/blahblah" }

      it { is_expected.to be_nil }
    end

    context "when pointer is relative_to a different pointer" do
      let(:pointer) { "#../version" }
      let(:relative_to) { "#/info/title" }

      it { is_expected.to eq "1.0.0" }
    end
  end
end
