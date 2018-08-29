# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::ServerVariable do
  include Helpers::Context

  it_behaves_like "node object factory",
                  Openapi3Parser::Node::ServerVariable do
    let(:input) do
      {
        "enum" => %w[8443 443],
        "default" => "8443"
      }
    end

    let(:context) { create_context(input) }
  end

  describe "enum" do
    subject(:factory) { described_class.new(context) }
    let(:context) { create_context("enum" => enum, "default" => "test") }

    context "when enum is not empty" do
      let(:enum) { %w[test] }
      it { is_expected.to be_valid }
    end

    context "when enum is empty" do
      let(:enum) { [] }
      it { is_expected.to have_validation_error("#/enum") }
    end
  end
end
