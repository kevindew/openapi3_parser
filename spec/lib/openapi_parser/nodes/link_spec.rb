# frozen_string_literal: true

require "openapi_parser/nodes/link"
require "openapi_parser/nodes/server"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Link do
  let(:operation_ref_input) { nil }
  let(:operation_id_input) { nil }
  let(:parameters_input) { nil }
  let(:request_body_input) { nil }
  let(:description_input) { nil }
  let(:server_input) { nil }

  let(:input) do
    {
      "operationRef" => operation_ref_input,
      "operationId" => operation_id_input,
      "parameters" => parameters_input,
      "requestBody" => request_body_input,
      "description" => description_input,
      "server" => server_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "operationRef field" do
    include_examples "node field", "operationRef",
                     required: false,
                     valid_input: "#/reference",
                     invalid_input: 123,
                     let_name: :operation_ref_input
  end

  describe ".operation_ref" do
    let(:operation_ref_input) { "#/reference" }
    subject { described_class.new(input, context).operation_ref }
    it { is_expected.to eq operation_ref_input }
  end

  describe "operationId field" do
    include_examples "node field", "operationId",
                     required: false,
                     valid_input: "getUserAddress",
                     invalid_input: 123,
                     let_name: :operation_id_input
  end

  describe ".operation_id" do
    let(:operation_id_input) { "getUserAddress" }
    subject { described_class.new(input, context).operation_id }
    it { is_expected.to eq operation_id_input }
  end

  describe "parameters field" do
    include_examples "node field", "parameters",
                     required: false,
                     valid_input: { "nested" => { "hash" => "objects" } },
                     invalid_input: { "simple" => "hash" }
  end

  describe ".parameters" do
    let(:parameters_input) do
      { "key" => { "key" => "value" } }
    end
    subject { described_class.new(input, context).parameters }
    it { is_expected.to match parameters_input }
  end

  describe "requestBody field" do
    include_examples "node field", "requestBody",
                     required: false,
                     valid_input: "Anything",
                     let_name: :request_body_input
  end

  describe ".requestBody" do
    let(:request_body_input) { %w[any type] }
    subject { described_class.new(input, context).request_body }
    it { is_expected.to eq request_body_input }
  end

  describe "description field" do
    include_examples "node field", "description",
                     required: false,
                     valid_input: "A link",
                     invalid_input: 123
  end

  describe ".description" do
    let(:description_input) { "A link description" }
    subject { described_class.new(input, context).description }
    it { is_expected.to eq description_input }
  end

  describe "server field" do
    include_examples "node field", "server",
                     required: false,
                     valid_input: { "url" => "https://www.radiohead.com" },
                     invalid_input: 123
  end

  describe ".server" do
    let(:server_input) do
      { "url" => "http://www.bucketheadpikes.com" }
    end
    subject { described_class.new(input, context).server }
    it { is_expected.to match an_instance_of(OpenapiParser::Nodes::Server) }
  end
end
