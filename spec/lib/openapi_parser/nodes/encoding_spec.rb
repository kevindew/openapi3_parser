# frozen_string_literal: true

require "openapi_parser/nodes/encoding"
require "openapi_parser/nodes/header"
require "openapi_parser/context"
require "openapi_parser/document"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Encoding do
  let(:content_type_input) { nil }
  let(:headers_input) { nil }
  let(:style_input) { nil }
  let(:explode_input) { nil }
  let(:allow_reserved_input) { nil }

  let(:input) do
    {
      "contentType" => content_type_input,
      "headers" => headers_input,
      "style" => style_input,
      "explode" => explode_input,
      "allowReserved" => allow_reserved_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { OpenapiParser::Document.new(document_input) }
  let(:context) { OpenapiParser::Context.root(document) }
  let(:document_input) { {} }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "contentType field" do
    include_examples "node field", "contentType",
                     required: false,
                     valid_input: "application/octet-stream",
                     invalid_input: 123,
                     let_name: :content_type_input
  end

  describe ".content_type" do
    let(:content_type_input) { "image/*" }
    subject { described_class.new(input, context).content_type }
    it { is_expected.to be content_type_input }
  end

  describe "headers field" do
    include_examples "node field", "headers",
                     required: false,
                     valid_input: { "key" => { "name" => "header" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:headers_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "name" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".headers" do
    let(:headers_input) do
      {
        "field" => { "name" => "Header" }
      }
    end

    subject(:headers) { described_class.new(input, context).headers }

    it "returns a hash of Header objects" do
      expect(headers).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Header)
        )
      )
    end
  end

  describe "style field" do
    include_examples "node field", "style",
                     required: false,
                     valid_input: "simple",
                     invalid_input: %w[a b c]
  end

  describe ".style" do
    let(:style_input) { "form" }
    subject { described_class.new(input, context).style }
    it { is_expected.to be style_input }
  end

  describe "explode field" do
    include_examples "node field", "explode",
                     required: false,
                     valid_input: true,
                     invalid_input: "green",
                     default: true
  end

  describe ".explode" do
    let(:explode_input) { false }
    subject { described_class.new(input, context).explode }
    it { is_expected.to be explode_input }
  end

  describe "allowReserved field" do
    include_examples "node field", "allowReserved",
                     required: false,
                     valid_input: true,
                     invalid_input: "green",
                     default: false,
                     let_name: :allow_reserved_input
  end

  describe ".allow_reserved" do
    let(:allow_reserved_input) { false }
    subject { described_class.new(input, context).allow_reserved }
    it { is_expected.to be allow_reserved_input }
  end
end
