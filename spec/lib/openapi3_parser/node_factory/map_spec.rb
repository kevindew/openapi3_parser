# frozen_string_literal: true

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Map do
  include Helpers::Context
  let(:node_factory_context) { create_node_factory_context(input) }
  let(:input) { {} }

  let(:allow_extensions) { false }
  let(:default) { {} }
  let(:value_input_type) { nil }
  let(:value_factory) { nil }
  let(:validate) { nil }

  let(:instance) do
    described_class.new(node_factory_context,
                        allow_extensions: allow_extensions,
                        default: default,
                        value_input_type: value_input_type,
                        value_factory: value_factory,
                        validate: validate)
  end

  it_behaves_like "node factory", ::Hash

  describe "non hash input" do
    subject { instance }

    let(:input) { "a string" }

    it "doesn't raise an error" do
      expect { instance }.not_to raise_error
    end

    it { is_expected.not_to be_valid }
  end

  describe "#node" do
    subject { instance.node(node_context) }

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end

    it { is_expected.to be_a(Openapi3Parser::Node::Map) }

    context "when input is expected to contain hashes" do
      let(:input) { { "a" => {}, "b" => 1 } }
      let(:value_input_type) { Hash }

      it "raises an InvalidType error" do
        error_type = Openapi3Parser::Error::InvalidType
        error_message = "Invalid type for #/b: Expected Object"
        expect { instance.node(node_context) }
          .to raise_error(error_type, error_message)
      end
    end

    context "when input is nil and default is an empty hash" do
      let(:input) { nil }
      let(:default) { {} }

      it { is_expected.to be_a(Openapi3Parser::Node::Map) }
    end

    context "when input is nil and default is nil" do
      let(:input) { nil }
      let(:default) { nil }

      it { is_expected.to be_nil }
    end

    context "when a not string key is passed" do
      let(:input) do
        {
          1 => { "name" => "Kenneth" }
        }
      end

      it "raises an InvalidType error" do
        expect { instance.node(node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end

    context "when value_input_type does not match" do
      let(:value_input_type) { Integer }
      let(:input) do
        {
          "item" => { "name" => "Kenneth" }
        }
      end

      it "raises an InvalidType error" do
        expect { instance.node(node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end

    context "when value_input_type does not match on an extension" do
      let(:allow_extensions) { true }
      let(:value_input_type) { Integer }
      let(:input) do
        {
          "real" => 1,
          "x-item" => { "name" => "Kenneth" }
        }
      end

      it "doesn't raise an InvalidType error" do
        expect { instance.node(node_context) }.not_to raise_error
      end
    end

    context "when value_factory is set" do
      subject(:item) { instance.node(node_context)["item"] }

      let(:value_factory) { Openapi3Parser::NodeFactory::Contact }
      let(:input) do
        {
          "item" => { "name" => "Kenneth" }
        }
      end

      it "returns items created by the value factory" do
        expect(item).to be_a(Openapi3Parser::Node::Contact)
      end
    end

    context "when validation is set and failing" do
      let(:validate) do
        ->(validatable) { validatable.add_error("Fail") }
      end

      it "raises an error" do
        expect { instance.node(node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end
end
