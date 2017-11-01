# frozen_string_literal: true

require "openapi_parser/nodes/media_type"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/example"
require "openapi_parser/nodes/encoding"
require "openapi_parser/context"
require "openapi_parser/document"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::MediaType do
  let(:schema_input) { nil }
  let(:example_input) { nil }
  let(:examples_input) { nil }
  let(:encoding_input) { nil }

  let(:input) do
    {
      "schema" => schema_input,
      "example" => example_input,
      "examples" => examples_input,
      "encoding" => encoding_input
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

  describe "schema field" do
    include_examples "node field", "schema",
                     required: false,
                     valid_input: { "title" => "My Schema" },
                     invalid_input: 123

    context "when input is a reference" do
      let(:schema_input) do
        {
          "$ref" => "#/a_schema"
        }
      end

      let(:document_input) do
        {
          "a_schema" => { "title" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".schema" do
    let(:schema_input) { { "title" => "A Schema" } }
    subject { described_class.new(input, context).schema }
    it { is_expected.to match an_instance_of(OpenapiParser::Nodes::Schema) }
  end

  describe "example field" do
    include_examples "node field", "example",
                     required: false,
                     valid_input: %w[any object]
  end

  describe ".example" do
    let(:example_input) { "title" }
    subject { described_class.new(input, context).example }
    it { is_expected.to eq example_input }
  end

  describe "examples field" do
    include_examples "node field", "examples",
                     required: false,
                     valid_input: { "key" => { "summary" => "My Example" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:examples_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "summary" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".examples" do
    let(:examples_input) do
      {
        "field" => { "summary" => "Summary" }
      }
    end

    subject(:examples) { described_class.new(input, context).examples }

    it "returns a hash of Example objects" do
      expect(examples).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Example)
        )
      )
    end
  end

  describe "encoding field" do
    include_examples "node field", "encoding",
                     required: false,
                     valid_input: { "key" => { "contentType" => "image/*" } },
                     invalid_input: 123
  end

  describe ".encoding" do
    let(:encoding_input) do
      {
        "field" => { "contentType" => "text/plain" }
      }
    end

    subject(:encoding) { described_class.new(input, context).encoding }

    it "returns a hash of Encoding objects" do
      expect(encoding).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Encoding)
        )
      )
    end
  end
end
