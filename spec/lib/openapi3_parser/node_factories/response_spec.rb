# frozen_string_literal: true

require "openapi3_parser/node_factories/response"
require "openapi3_parser/node/response"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Response do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Response do
    let(:input) do
      {
        "description" => "A simple string response",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "string"
            }
          }
        },
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Remaining" => {
            "description" => "The number of remaining requests in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Reset" => {
            "description" => "The number of seconds left in the current"\
                             " period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end

  describe "content" do
    subject { described_class.new(context) }
    let(:context) do
      create_context("description" => "Description", "content" => content)
    end

    context "when content is an empty hash" do
      let(:content) { {} }

      it { is_expected.to be_valid }
    end

    context "when content has a valid media type" do
      let(:content) do
        {
          "application/json" => {}
        }
      end

      it { is_expected.to be_valid }
    end

    context "when content has an invalid valid media type" do
      let(:content) do
        {
          "bad-media-type" => {}
        }
      end

      it do
        is_expected
          .to have_validation_error("#/content/bad-media-type")
          .with_message(%("bad-media-type" is not a valid media type))
      end
    end
  end

  describe "links" do
    subject { described_class.new(context) }
    let(:context) do
      create_context(
        "description" => "Description",
        "links" => { key => { "operationRef" => "#/test" } }
      )
    end

    context "when key is invalid" do
      let(:key) { "Invalid Key" }
      it { is_expected.not_to be_valid }
    end

    context "when key is valid" do
      let(:key) { "valid.key" }
      it { is_expected.to be_valid }
    end
  end
end
