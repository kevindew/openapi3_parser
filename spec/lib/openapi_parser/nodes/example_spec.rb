# frozen_string_literal: true

require "openapi_parser/nodes/example"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Example do
  let(:summary_input) { nil }
  let(:description_input) { nil }
  let(:value_input) { nil }
  let(:external_value_input) { nil }

  let(:input) do
    {
      "summary" => summary_input,
      "description" => description_input,
      "value" => value_input,
      "externalValue" => external_value_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "summary field" do
    include_examples "node field", "summary",
                     required: false,
                     valid_input: "My Summary",
                     invalid_input: 123
  end

  describe ".summary" do
    let(:summary_input) { "A summary" }
    subject { described_class.new(input, context).summary }
    it { is_expected.to be summary_input }
  end

  describe "description field" do
    include_examples "node field", "description",
                     required: false,
                     valid_input: "My description",
                     invalid_input: 123
  end

  describe ".description" do
    let(:description_input) { "An awesome description" }
    subject { described_class.new(input, context).description }
    it { is_expected.to be description_input }
  end

  describe "value field" do
    include_examples "node field", "value",
                     required: false,
                     valid_input: { "could be" => ["anything"] }
  end

  describe ".value" do
    let(:value_input) { %w[a b c] }
    subject { described_class.new(input, context).value }
    it { is_expected.to be value_input }
  end

  describe "externalValue field" do
    include_examples "node field", "externalValue",
                     required: false,
                     valid_input: "https://muse.mu",
                     invalid_input: 123,
                     let_name: :external_value_input
  end

  describe ".external_value" do
    let(:external_value_input) { "https://www.heretodaygonetohell.com" }
    subject { described_class.new(input, context).external_value }
    it { is_expected.to be external_value_input }
  end
end
