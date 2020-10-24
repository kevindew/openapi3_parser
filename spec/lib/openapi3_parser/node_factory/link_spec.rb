# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Link do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Link do
    let(:input) do
      {
        "operationRef" => "#/paths/~12.0~1repositories~1{username}/get",
        "parameters" => { "username" => "$response.body#/username" }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "mutually exclusive operationRef operationId" do
    subject { described_class.new(node_factory_context) }

    let(:node_factory_context) do
      create_node_factory_context({ "operationRef" => operation_ref,
                                    "operationId" => operation_id })
    end

    let(:operation_ref) { nil }
    let(:operation_id) { nil }

    context "when operationRef or operationId is provided" do
      it do
        expect(subject)
          .to have_validation_error("#/")
          .with_message(
            "One of operationRef and operationId is required"
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
        expect(subject)
          .to have_validation_error("#/")
          .with_message(
            "operationRef and operationId are mutually exclusive fields"
          )
      end
    end
  end
end
