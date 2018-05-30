# frozen_string_literal: true

require "openapi3_parser/node_factory/responses"
require "openapi3_parser/node/responses"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Responses do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Responses do
    let(:input) do
      {
        "200" => {
          "description" => "a pet to be returned",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        },
        "default" => {
          "description" => "Unexpected error",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end

  describe "valid keys" do
    let(:response) do
      {
        "description" => "A response",
        "content" => {
          "application/json" => {
            "schema" => { "type" => "string" }
          }
        }
      }
    end

    subject { described_class.new(context) }
    let(:context) { create_context(key_value => response) }

    context "when the key_value is a status code range" do
      let(:key_value) { "2XX" }
      it { is_expected.to be_valid }
    end

    context "when the key_value is a status code" do
      let(:key_value) { "503" }
      it { is_expected.to be_valid }
    end

    context "when the key_value is a random string" do
      let(:key_value) { "5tsd8s" }
      it do
        is_expected
          .to have_validation_error("#/")
          .with_message(
            "Invalid responses keys: '5tsd8s' - default, status codes and "\
            "status code ranges allowed"
          )
      end
    end

    context "when the key_value is an invalid status code" do
      let(:key_value) { "999" }
      it { is_expected.to have_validation_error("#/") }
    end
  end
end
