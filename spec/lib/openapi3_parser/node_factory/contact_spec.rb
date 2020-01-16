# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Contact do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Contact do
    let(:input) do
      {
        "name" => "Contact"
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "url" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:node_factory_context) { create_node_factory_context({ "url" => url }) }

    context "when url is an actual url" do
      let(:url) { "https://example.com/path" }
      it { is_expected.to be_valid }
    end

    context "when url is not a url" do
      let(:url) { "not a url" }
      it { is_expected.to have_validation_error("#/url") }
    end
  end

  describe "email" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:node_factory_context) do
      create_node_factory_context({ "email" => email })
    end

    context "when email is an actual email" do
      let(:email) { "kevin@example.com" }
      it { is_expected.to be_valid }
    end

    context "when email is not a email" do
      let(:email) { "not an email" }
      it { is_expected.to have_validation_error("#/email") }
    end
  end
end
