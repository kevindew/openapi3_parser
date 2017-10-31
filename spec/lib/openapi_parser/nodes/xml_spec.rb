# frozen_string_literal: true

require "openapi_parser/nodes/xml"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Xml do
  let(:name_input) { nil }
  let(:namespace_input) { nil }
  let(:prefix_input) { nil }
  let(:attribute_input) { nil }
  let(:wrapped_input) { nil }

  let(:input) do
    {
      "name" => name_input,
      "namespace" => namespace_input,
      "prefix" => prefix_input,
      "attribute" => attribute_input,
      "wrapped" => wrapped_input
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
                     required: false,
                     valid_input: "name",
                     invalid_input: 123
  end

  describe ".name" do
    let(:name_input) { "name" }
    subject { described_class.new(input, context).name }
    it { is_expected.to be name_input }
  end

  describe "namespace field" do
    include_examples "node field", "namespace",
                     required: false,
                     valid_input: "http://example.com/schema/sample",
                     invalid_input: 123
  end

  describe ".namespace" do
    let(:namespace_input) { "http://example.com/schema/sample" }
    subject { described_class.new(input, context).namespace }
    it { is_expected.to be namespace_input }
  end

  describe "prefix field" do
    include_examples "node field", "prefix",
                     required: false,
                     valid_input: "sample",
                     invalid_input: 123
  end

  describe ".prefix" do
    let(:prefix_input) { "sample" }
    subject { described_class.new(input, context).prefix }
    it { is_expected.to be prefix_input }
  end

  describe "attribute field" do
    include_examples "node field", "attribute",
                     required: false,
                     default: false,
                     valid_input: true,
                     invalid_input: "my string"
  end

  describe ".attribute" do
    let(:attribute_input) { true }
    subject { described_class.new(input, context).attribute }
    it { is_expected.to be attribute_input }
  end

  describe "wrapped field" do
    include_examples "node field", "wrapped",
                     required: false,
                     default: false,
                     valid_input: true,
                     invalid_input: "my string"
  end

  describe ".wrapped" do
    let(:wrapped_input) { true }
    subject { described_class.new(input, context).wrapped }
    it { is_expected.to be wrapped_input }
  end
end
