# frozen_string_literal: true

require "openapi_parser/nodes/header"
require "openapi_parser/nodes/external_documentation"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Header do
  let(:name_input) { "Pet" }
  let(:description_input) { nil }
  let(:external_docs_input) { nil }

  let(:input) do
    {
      "name" => name_input,
      "description" => description_input,
      "externalDocs" => external_docs_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "name field" do
    include_examples "node field", "name",
                     required: true,
                     valid_input: "Pets",
                     invalid_input: 123
  end

  describe ".name" do
    let(:name_input) { "Animals" }
    subject { described_class.new(input, context).name }
    it { is_expected.to be name_input }
  end

  describe "description field" do
    include_examples "node field", "description",
                     required: false,
                     valid_input: "My description",
                     invalid_input: 123
  end

  describe ".description" do
    let(:description_input) { "An awesome desription" }
    subject { described_class.new(input, context).description }
    it { is_expected.to be description_input }
  end

  describe "externalDocs field" do
    include_examples "node field", "externalDocs",
                     required: false,
                     valid_input: { "url" => "https://www.weezer.com" },
                     invalid_input: "test",
                     let_name: :external_docs_input
  end

  describe ".external_docs" do
    let(:external_docs_input) { { "url" => "https://www.megadeth.com" } }
    let(:expected_class) { OpenapiParser::Nodes::ExternalDocumentation }
    subject { described_class.new(input, context).external_docs }

    it { is_expected.to match instance_of(expected_class) }
  end
end
