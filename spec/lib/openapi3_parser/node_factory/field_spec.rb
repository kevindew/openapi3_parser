# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/node_factory/field"

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Field do
  include Helpers::Context

  let(:context) { create_context(input) }
  let(:input) { "input" }
  let(:input_type) { nil }
  let(:validate) { nil }

  let(:instance) do
    described_class.new(context, input_type: input_type, validate: validate)
  end

  it_behaves_like "node factory", ::Integer do
    let(:context) { create_context(1) }
  end

  describe "#node" do
    subject { instance.node }

    it { is_expected.to eq(input) }

    context "when input is nil" do
      let(:input) { nil }
      it { is_expected.to be_nil }
    end

    context "when input_type does not match" do
      let(:input_type) { Integer }
      let(:input) { "input" }

      it "raises an InvalidType error" do
        expect { instance.node }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end

    context "when validation is set and failing" do
      let(:validate) do
        ->(validatable) { validatable.add_error("Fail") }
      end

      it "raises an error" do
        expect { instance.node }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end
end
