# frozen_string_literal: true

require "openapi3_parser/node_factories/parameter"
require "openapi3_parser/node/parameter"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Parameter do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Parameter do
    let(:input) do
      {
        "name" => "id",
        "in" => "query",
        "description" => "ID of the object to fetch",
        "required" => false,
        "schema" => {
          "type" => "array",
          "items" => {
            "type" => "string"
          }
        },
        "style" => "form",
        "explode" => true
      }
    end

    let(:context) { create_context(input) }
  end

  describe "in" do
    subject(:factory) { described_class.new(context) }
    let(:context) { create_context("name" => "name", "in" => in_value) }

    context "when in is 'query'" do
      let(:in_value) { "query" }
      it { is_expected.to be_valid }
    end

    context "when in is 'header'" do
      let(:in_value) { "header" }
      it { is_expected.to be_valid }
    end

    context "when in is 'path'" do
      let(:in_value) { "path" }
      it { is_expected.to be_valid }
    end

    context "when in is 'cookie'" do
      let(:in_value) { "cookie" }
      it { is_expected.to be_valid }
    end

    context "when in is a different value" do
      let(:in_value) { "different" }
      it { is_expected.not_to be_valid }
    end
  end
end
