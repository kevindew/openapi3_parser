# frozen_string_literal: true

require "openapi3_parser/node_factories/link"
require "openapi3_parser/node/link"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Link do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Link do
    let(:input) do
      {
        "operationRef" => "#/paths/~12.0~1repositories~1{username}/get",
        "parameters" => { "username" => "$response.body#/username" }
      }
    end

    let(:context) { create_context(input) }
  end

  describe "mutually exclusive operationRef operationId" do
    subject { described_class.new(context) }

    let(:context) do
      create_context(
        "operationRef" => operation_ref,
        "operationId" => operation_id
      )
    end

    let(:operation_ref) { nil }
    let(:operation_id) { nil }

    context "when operationRef or operationId is provided" do
      it do
        is_expected
          .to have_validation_error("#/")
          .with_message(
            "one of operationRef and operationId is required"
          )
      end
    end

    context "when operationRef is provided" do
      let(:operation_ref) { "#/test" }
      it { is_expected.to be_valid }
    end

    context "when operationId is provided" do
      let(:operation_id) { "getOperation" }
      it { is_expected.to be_valid }
    end

    context "when both are provided" do
      let(:operation_ref) { "#/test" }
      let(:operation_id) { "getOperation" }
      it do
        is_expected
          .to have_validation_error("#/")
          .with_message(
            "operationRef and operationId are mutually exclusive fields"
          )
      end
    end
  end
end
