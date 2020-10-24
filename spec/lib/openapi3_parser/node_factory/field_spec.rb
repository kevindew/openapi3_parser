# frozen_string_literal: true

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Field do
  include Helpers::Context

  let(:node_factory_context) { create_node_factory_context(input) }
  let(:input) { "input" }
  let(:input_type) { nil }
  let(:validate) { nil }

  let(:instance) do
    described_class.new(node_factory_context,
                        input_type: input_type,
                        validate: validate)
  end

  it_behaves_like "node factory", ::Integer do
    let(:node_factory_context) { create_node_factory_context(1) }
  end

  describe "#node" do
    subject { instance.node(node_context) }

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end

    it { is_expected.to eq(input) }

    context "when input is nil" do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end

    context "when input_type does not match" do
      let(:input_type) { Integer }
      let(:input) { "input" }

      it "raises an InvalidType error" do
        expect { instance.node(node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidType)
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
