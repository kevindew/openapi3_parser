# frozen_string_literal: true

require "openapi3_parser/node_factories/parameter"
require "openapi3_parser/node/parameter"

require "support/helpers/context"
require "support/mutually_exclusive_example"
require "support/node_object_factory"

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

  describe "default style value" do
    subject(:node) { described_class.new(context).node }
    let(:context) do
      create_context("name" => "name", "in" => in_value, "required" => true)
    end

    context "when in is path" do
      let(:in_value) { "path" }
      it "has a value of simple" do
        expect(node["style"]).to eq("simple")
      end
    end

    context "when in is header" do
      let(:in_value) { "header" }
      it "has a value of simple" do
        expect(node["style"]).to eq("simple")
      end
    end

    context "when in is query" do
      let(:in_value) { "query" }
      it "has a value of form" do
        expect(node["style"]).to eq("form")
      end
    end
  end

  describe "default explode value" do
    subject(:node) { described_class.new(context).node }
    let(:context) do
      create_context("name" => "name", "in" => "query", "style" => style)
    end

    context "when style is form" do
      let(:style) { "form" }
      it "has a value of true" do
        expect(node["explode"]).to be true
      end
    end

    context "when style is simple" do
      let(:style) { "simple" }
      it "has a value of false" do
        expect(node["explode"]).to be false
      end
    end
  end

  describe "content" do
    subject(:factory) { described_class.new(context) }
    let(:context) do
      create_context("name" => "name", "in" => "query", "content" => content)
    end
    let(:message) { "Must only have one item" }

    context "when there is a nil content entry" do
      let(:content) { nil }
      it { is_expected.to be_valid }

      it "defaults to a nil value" do
        expect(factory.node.content).to be nil
      end
    end

    context "when there are no content entries" do
      let(:content) { {} }
      it do
        is_expected
          .to have_validation_error("#/content")
          .with_message(message)
      end
    end

    context "when there is a single content entry" do
      let(:content) do
        {
          "media_type" => {
            "schema" => { "type" => "string" }
          }
        }
      end
      it { is_expected.to be_valid }
    end

    context "when there are multiple content entries" do
      let(:content) do
        {
          "media_type_1" => {
            "schema" => { "type" => "string" }
          },
          "media_type_2" => {
            "schema" => { "type" => "string" }
          }
        }
      end

      it do
        is_expected
          .to have_validation_error("#/content")
          .with_message(message)
      end
    end
  end

  it_behaves_like "mutually exclusive example" do
    let(:context) do
      create_context(
        "name" => "name",
        "in" => "query",
        "example" => example,
        "examples" => examples
      )
    end
  end
end
