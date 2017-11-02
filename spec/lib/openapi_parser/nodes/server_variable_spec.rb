# frozen_string_literal: true

require "openapi_parser/nodes/server_variable"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::ServerVariable do
  let(:enum_input) { nil }
  let(:default_input) { "demo" }
  let(:description_input) { nil }

  let(:input) do
    {
      "enum" => enum_input,
      "default" => default_input,
      "description" => description_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "enum field" do
    include_examples "node field", "enum",
                     required: false,
                     valid_input: %w[array of strings],
                     invalid_input: [0, 2]
  end

  describe ".enum" do
    let(:enum_input) { %w[array of strings] }
    subject { described_class.new(input, context).enum }
    it { is_expected.to eq enum_input }
  end

  describe "default field" do
    include_examples "node field", "default",
                     required: true,
                     valid_input: "demo",
                     invalid_input: [0, 2]
  end

  describe ".default" do
    let(:default_input) { "demo" }
    subject { described_class.new(input, context).default }
    it { is_expected.to eq default_input }
  end

  describe "description field" do
    include_examples "node field", "description",
                     required: false,
                     valid_input: "My description",
                     invalid_input: [0, 2]
  end

  describe ".description" do
    let(:description_input) { "An awesome description" }
    subject { described_class.new(input, context).description }
    it { is_expected.to eq description_input }
  end
end
