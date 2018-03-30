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
    let(:context) do
      create_context("name" => "name", "in" => in_value, "required" => true)
    end

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
      it do
        is_expected
          .to have_validation_error("#/in")
          .with_message("in can only be header, query, cookie, or path")
      end
    end
  end

  describe "required" do
    subject(:factory) { described_class.new(context) }
    let(:in_value) { "path" }
    let(:context) do
      create_context("name" => "name", "in" => in_value, "required" => required)
    end

    context "when in is path and required is true" do
      let(:required) { true }
      it { is_expected.to be_valid }
    end

    context "when in is path and required is false" do
      let(:required) { false }
      it do
        is_expected
          .to have_validation_error("#/required")
          .with_message("Must be included and true for a path parameter")
      end
    end

    context "when in is path and required is ommitted" do
      let(:required) { nil }
      it { is_expected.to have_validation_error("#/required") }
    end
  end
end
