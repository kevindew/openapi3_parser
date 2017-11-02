# frozen_string_literal: true

require "openapi_parser/nodes/server"
require "openapi_parser/nodes/server_variable"
require "openapi_parser/context"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Server do
  let(:url_input) { "https://www.daringfireball.net" }
  let(:description_input) { nil }
  let(:variables_input) { nil }

  let(:input) do
    {
      "url" => url_input,
      "description" => description_input,
      "variables" => variables_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "url field" do
    include_examples "node field", "url",
                     required: true,
                     valid_input: "any string",
                     invalid_input: [0, 2]
  end

  describe ".url" do
    let(:url_input) do
      "https://{username}.gigantic-server.com:{port}/{basePath}"
    end
    subject { described_class.new(input, context).url }
    it { is_expected.to eq url_input }
  end

  describe "description field" do
    include_examples "node field", "description",
                     required: false,
                     valid_input: "My Description",
                     invalid_input: 123
  end

  describe ".description" do
    let(:description_input) { "A Description" }
    subject { described_class.new(input, context).description }
    it { is_expected.to eq description_input }
  end

  describe "variables field" do
    include_examples "node field", "variables",
                     required: false,
                     valid_input: { "var_name" => { "default" => "test" } },
                     invalid_input: [0, 2]
  end

  describe ".variables" do
    let(:variables_input) do
      {
        "var_name" => { "default" => "test" }
      }
    end

    subject(:variables) { described_class.new(input, context).variables }

    it "returns a hash of ServerVariable objects" do
      expect(variables).to match(
        a_hash_including(
          "var_name" => an_instance_of(OpenapiParser::Nodes::ServerVariable)
        )
      )
    end
  end
end
