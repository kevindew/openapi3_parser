# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::PathItem do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::PathItem do
    let(:input) do
      {
        "$ref" => "#/path_items/example",
        "get" => {
          "description" => "Returns pets based on ID",
          "summary" => "Find pets by ID",
          "operationId" => "getPetsById",
          "responses" => {
            "200" => {
              "description" => "pet response",
              "content" => {
                "*/*" => {
                  "schema" => {
                    "type" => "array",
                    "items" => { "type" => "string" }
                  }
                }
              }
            },
            "default" => {
              "description" => "error payload",
              "content" => {
                "text/html" => {
                  "schema" => { "type" => "string" }
                }
              }
            }
          }
        },
        "parameters" => [
          {
            "name" => "id",
            "in" => "path",
            "description" => "ID of pet to use",
            "required" => true,
            "schema" => {
              "type" => "array",
              "items" => {
                "type" => "string"
              }
            },
            "style" => "simple"
          }
        ]
      }
    end

    let(:document_input) do
      {
        "path_items" => {
          "example" => {
            "summary" => "Example"
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "parameters" do
    subject do
      described_class.new(
        create_node_factory_context("parameters" => parameters)
      )
    end

    context "when there are no duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "header" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.to be_valid }
    end

    context "when there are duplicate parameters" do
      let(:parameters) do
        [
          { "name" => "id", "in" => "query" },
          { "name" => "id", "in" => "query" }
        ]
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "merging with reference" do
    let(:input) do
      { "$ref" => "#/path_items/example" }
    end

    let(:document_input) do
      {
        "path_items" => { "example" => reference_input }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end

    let(:reference_input) do
      { "summary" => "My summary" }
    end

    let(:instance) { described_class.new(node_factory_context) }

    it "can be accessed via resolved_input" do
      expect(instance.resolved_input).to match(
        hash_including("summary" => "My summary")
      )
    end

    it "is within the node" do
      node_context = node_factory_context_to_node_context(node_factory_context)
      expect(instance.node(node_context).summary).to eq "My summary"
    end

    context "when both structures contain the same field" do
      let(:input) do
        {
          "$ref" => "#/path_items/example",
          "summary" => "A different summary"
        }
      end

      it "uses the input at a higher priority than the reference" do
        expect(instance.resolved_input).to match(
          hash_including("summary" => "A different summary")
        )

        node_context = node_factory_context_to_node_context(
          node_factory_context
        )

        expect(instance.node(node_context).summary)
          .to eq "A different summary"
      end
    end
  end
end
