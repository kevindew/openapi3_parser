# frozen_string_literal: true

require "openapi_parser/nodes/parameter"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/example"
require "openapi_parser/context"
require "openapi_parser/document"
require "openapi_parser/error"

require "support/extendable_node"
require "support/node_field"

RSpec.describe OpenapiParser::Nodes::Parameter do
  let(:name_input) { "name" }
  let(:in_input) { "query" }

  let(:required_input) do
    {
      "name" => name_input,
      "in" => in_input
    }
  end

  let(:optional_input) { {} }

  let(:input) { required_input.merge(optional_input).merge(extensions) }

  let(:extensions) { {} }

  let(:document_input) { {} }

  let(:context) { OpenapiParser::Context.root(document) }
  let(:document) { OpenapiParser::Document.new(document_input) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "name field" do
    include_examples "node field", "name",
                     required: true,
                     valid_input: "name",
                     invalid_input: 123
  end

  describe ".name" do
    let(:name_input) { "name" }
    subject { described_class.new(input, context).name }

    it { is_expected.to eq name_input }
  end

  describe "in field" do
    include_examples "node field", "in",
                     required: true,
                     valid_input: "query",
                     invalid_input: 123
  end

  describe ".in" do
    let(:in_input) { "query" }
    subject { described_class.new(input, context).in }

    it { is_expected.to eq in_input }
  end

  describe "description field" do
    let(:description_input) { "description" }
    let(:optional_input) { { "description" => description_input } }

    include_examples "node field", "description",
                     required: false,
                     valid_input: "description",
                     invalid_input: 123
  end

  describe ".description" do
    let(:optional_input) { { "description" => "description" } }
    subject { described_class.new(input, context).description }

    it { is_expected.to eq optional_input["description"] }
  end

  describe "required field" do
    let(:required_field_input) { true }
    let(:optional_input) { { "required" => required_field_input } }

    include_examples "node field", "required",
                     required: false,
                     valid_input: true,
                     invalid_input: 123,
                     default: false,
                     let_name: :required_field_input
  end

  describe ".required" do
    let(:optional_input) { { "required" => true } }
    subject { described_class.new(input, context).required }

    it { is_expected.to eq optional_input["required"] }
  end

  describe "deprecated field" do
    let(:deprecated_input) { true }
    let(:optional_input) { { "deprecated" => deprecated_input } }

    include_examples "node field", "deprecated",
                     required: false,
                     valid_input: true,
                     invalid_input: 123,
                     default: false
  end

  describe ".deprecated" do
    let(:optional_input) { { "deprecated" => true } }
    subject { described_class.new(input, context).deprecated }

    it { is_expected.to eq optional_input["deprecated"] }
  end

  describe "allowEmptyValue field" do
    let(:allow_empty_value_input) { true }
    let(:optional_input) { { "allowEmptyValue" => allow_empty_value_input } }

    include_examples "node field", "allowEmptyValue",
                     required: false,
                     valid_input: true,
                     invalid_input: 123,
                     default: false,
                     let_name: :allow_empty_value_input
  end

  describe ".allow_empty_value" do
    let(:optional_input) { { "allowEmptyValue" => true } }
    subject { described_class.new(input, context).allow_empty_value }

    it { is_expected.to eq optional_input["allowEmptyValue"] }
  end

  describe "style field" do
    let(:style_input) { nil }
    let(:optional_input) { { "style" => style_input } }

    include_examples "node field", "style",
                     required: false,
                     valid_input: "matrix",
                     invalid_input: 123

    context "when 'in' is 'query'" do
      let(:in_input) { "query" }

      it "has a default of 'form'" do
        expect(
          described_class.new(input, context)["style"]
        ).to eq "form"
      end
    end

    context "when 'in' is 'path'" do
      let(:in_input) { "path" }

      it "has a default of 'simple'" do
        expect(
          described_class.new(input, context)["style"]
        ).to eq "simple"
      end
    end

    context "when 'in' is 'header'" do
      let(:in_input) { "header" }

      it "has a default of 'simple'" do
        expect(
          described_class.new(input, context)["style"]
        ).to eq "simple"
      end
    end

    context "when 'in' is 'cookie'" do
      let(:in_input) { "cookie" }

      it "has a default of 'form'" do
        expect(
          described_class.new(input, context)["style"]
        ).to eq "form"
      end
    end
  end

  describe ".style" do
    let(:optional_input) { { "style" => "matrix" } }
    subject { described_class.new(input, context).style }

    it { is_expected.to eq optional_input["style"] }
  end

  describe "explode field" do
    let(:explode_input) { nil }
    let(:style_input) { nil }
    let(:optional_input) do
      {
        "explode" => explode_input,
        "style" => style_input
      }
    end

    include_examples "node field", "explode",
                     required: false,
                     valid_input: true,
                     invalid_input: "string"

    context "when style is 'form'" do
      let(:style_input) { "form" }

      it "has a default of true" do
        expect(
          described_class.new(input, context)["explode"]
        ).to eq true
      end
    end

    context "when style is not 'form'" do
      let(:style_input) { "simple" }

      it "has a default of false" do
        expect(
          described_class.new(input, context)["explode"]
        ).to eq false
      end
    end

    context "when style is not set and 'in' is 'cookie'" do
      let(:in_input) { "cookie" }

      it "has a default of true" do
        expect(
          described_class.new(input, context)["explode"]
        ).to eq true
      end
    end
  end

  describe ".explode" do
    let(:optional_input) { { "explode" => false } }
    subject { described_class.new(input, context).explode }

    it { is_expected.to eq optional_input["explode"] }
  end

  describe "allowReserved field" do
    let(:allow_reserved_input) { true }
    let(:optional_input) { { "allowReserved" => allow_reserved_input } }

    include_examples "node field", "allowReserved",
                     required: false,
                     valid_input: true,
                     invalid_input: 123,
                     default: false,
                     let_name: :allow_reserved_input
  end

  describe ".allow_reserved" do
    let(:optional_input) { { "allowReserved" => true } }
    subject { described_class.new(input, context).allow_reserved }

    it { is_expected.to eq optional_input["allowReserved"] }
  end

  describe "schema field" do
    let(:schema_input) { true }
    let(:optional_input) { { "schema" => schema_input } }

    include_examples "node field", "schema",
                     required: false,
                     valid_input: { "title" => "Test" },
                     invalid_input: "not a hash"

    context "when input is a reference" do
      let(:schema_input) do
        { "$ref" => "#/reference" }
      end

      let(:document_input) do
        {
          "reference" => { "title" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".schema" do
    let(:optional_input) { { "schema" => { "title" => "Test" } } }
    subject(:schema) { described_class.new(input, context).schema }

    it "returns a Schema objects" do
      expect(schema).to match(
        an_instance_of(OpenapiParser::Nodes::Schema)
      )
    end
  end

  describe "example field" do
    let(:example_input) { nil }
    let(:optional_input) { { "example" => example_input } }
    include_examples "node field", "example",
                     required: false,
                     valid_input: %w[any object]
  end

  describe ".example" do
    let(:optional_input) { { "example" => "title" } }
    subject { described_class.new(input, context).example }
    it { is_expected.to eq optional_input["example"] }
  end

  describe "examples field" do
    let(:examples_input) { nil }
    let(:optional_input) { { "examples" => examples_input } }
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
    let(:optional_input) do
      {
        "examples" => {
          "field" => { "summary" => "Summary" }
        }
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

  describe "content field" do
    let(:content_input) { nil }
    let(:optional_input) { { "content" => content_input } }
    include_examples "node field", "content",
                     required: false,
                     valid_input: { "key" => { "example" => "Some text" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:content_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "example" => "Some text" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".content" do
    let(:optional_input) do
      {
        "content" => {
          "field" => { "example" => "Some text" }
        }
      }
    end

    subject(:content) { described_class.new(input, context).content }

    it "returns a hash of MediaType objects" do
      expect(content).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::MediaType)
        )
      )
    end
  end
end
