# frozen_string_literal: true

require "openapi_parser/nodes/external_documentation"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::ExternalDocumentation do
  let(:description_input) { nil }
  let(:url_input) { "https://muse.mu" }

  let(:input) do
    {
      "description" => description_input,
      "url" => url_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

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

  describe "url field" do
    include_examples "node field", "url",
                     required: true,
                     valid_input: "https://muse.mu",
                     invalid_input: 123
  end

  describe ".url" do
    let(:url_input) { "https://www.heretodaygonetohell.com" }
    subject { described_class.new(input, context).url }
    it { is_expected.to be url_input }
  end
end
