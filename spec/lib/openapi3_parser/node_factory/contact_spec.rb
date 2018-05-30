# frozen_string_literal: true

require "openapi3_parser/node_factory/contact"
require "openapi3_parser/node/contact"

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

    let(:context) { create_context(input) }
  end

  describe "url" do
    subject(:factory) { described_class.new(context) }
    let(:context) { create_context("url" => url) }

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
    subject(:factory) { described_class.new(context) }
    let(:context) { create_context("email" => email) }

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
