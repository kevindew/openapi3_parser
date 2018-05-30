# frozen_string_literal: true

require "openapi3_parser/node_factory/xml"
require "openapi3_parser/node/xml"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Xml do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Xml do
    let(:input) do
      {
        "namespace" => "http://example.com/schema/sample",
        "prefix" => "sample"
      }
    end

    let(:context) { create_context(input) }
  end

  describe "namespace" do
    subject(:factory) { described_class.new(context) }
    let(:context) do
      create_context(
        "namespace" => namespace,
        "prefix" => "sample"
      )
    end

    context "when namespace is an actual uri" do
      let(:namespace) { "https://example.com/path" }
      it { is_expected.to be_valid }
    end

    context "when namespace is not a uri" do
      let(:namespace) { "not a url" }
      it do
        is_expected
          .to have_validation_error("#/namespace")
          .with_message(%("#{namespace}" is not a valid URI))
      end
    end
  end
end
