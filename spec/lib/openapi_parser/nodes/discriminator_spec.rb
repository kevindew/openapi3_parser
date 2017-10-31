# frozen_string_literal: true

require "openapi_parser/nodes/discriminator"
require "openapi_parser/context"

require "support/node_field"

RSpec.describe OpenapiParser::Nodes::Discriminator do
  let(:property_name_input) { "My Property" }
  let(:mapping_input) { nil }

  let(:input) do
    {
      "propertyName" => property_name_input,
      "mapping" => mapping_input
    }
  end

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  describe "propertyName field" do
    include_examples "node field", "propertyName",
                     required: true,
                     valid_input: "property input",
                     invalid_input: 123,
                     let_name: :property_name_input
  end

  describe ".property_name" do
    subject { described_class.new(input, context).property_name }
    it { is_expected.to be property_name_input }
  end

  describe "mapping field" do
    include_examples "node field", "mapping",
                     required: false,
                     valid_input: { "test" => "test" },
                     invalid_input: 123
  end

  describe ".mapping" do
    let(:mapping_input) { { "test" => "test" } }
    subject { described_class.new(input, context).mapping }
    it { is_expected.to be mapping_input }
  end
end
