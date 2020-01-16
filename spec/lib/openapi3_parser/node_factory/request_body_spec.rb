# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::RequestBody do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::RequestBody do
    let(:input) do
      {
        "description" => "user to add to the system",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "array",
              "items" => { "type" => "string" }
            }
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "content" do
    subject { described_class.new(node_factory_context) }
    let(:node_factory_context) do
      create_node_factory_context({ "content" => content })
    end

    context "when content is an empty hash" do
      let(:content) { {} }

      it do
        is_expected
          .to have_validation_error("#/content")
          .with_message("Expected to have at least 1 item")
      end
    end

    context "when content has a valid media type" do
      let(:content) do
        {
          "application/json" => {}
        }
      end

      it { is_expected.to be_valid }
    end

    context "when content has a valid media type range" do
      let(:content) do
        {
          "text/*" => {}
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

  describe "required" do
    subject do
      node_context = node_factory_context_to_node_context(node_factory_context)
      described_class.new(node_factory_context).node(node_context)["required"]
    end

    let(:node_factory_context) do
      create_node_factory_context({ "content" => { "*/*" => {} },
                                    "required" => required })
    end

    context "when required is set" do
      let(:required) { true }
      it { is_expected.to be true }
    end

    context "when required is not set" do
      let(:required) { nil }
      it { is_expected.to be false }
    end
  end
end
