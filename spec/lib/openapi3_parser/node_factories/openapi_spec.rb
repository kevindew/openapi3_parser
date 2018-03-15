# frozen_string_literal: true

require "openapi3_parser/node_factories/openapi"
require "openapi3_parser/node/openapi"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Openapi do
  include Helpers::Context
  let(:minimal_openapi_definition) do
    {
      "openapi" => "3.0.0",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {}
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Openapi do
    let(:input) { minimal_openapi_definition }
    let(:context) { create_context(input) }
  end

  context "when input is nil" do
    subject(:factory) { described_class.new(context) }
    let(:input) { nil }
    let(:context) { create_context(input) }

    it { is_expected.to_not be_valid }
    it "raises error accessing node" do
      expect { subject.node }.to raise_error(Openapi3Parser::Error)
    end
  end

  describe "tags" do
    subject(:factory) { described_class.new(context) }
    let(:input) { minimal_openapi_definition.merge("tags" => tags) }
    let(:context) { create_context(input) }

    context "when tags contains no duplicate names" do
      let(:tags) do
        [
          { "name" => "a" }
        ]
      end
      it { is_expected.to be_valid }
    end

    context "when tags contains duplicate names" do
      let(:tags) do
        [
          { "name" => "a" },
          { "name" => "a" }
        ]
      end
      it { is_expected.not_to be_valid }

      it "has a duplicate tags names error" do
        message = "Duplicate tag names: a"
        expect(factory.errors.first.message).to eq message
      end
    end
  end
end
