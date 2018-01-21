# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/nodes/map"

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Map do
  include Helpers::Context
  let(:context) { create_context(input, pointer_segments: pointer_segments) }
  let(:input) { {} }
  let(:pointer_segments) { [] }
  let(:value_input_type) { nil }
  let(:instance) do
    described_class.new(context, value_input_type: value_input_type)
  end

  describe "#node" do
    subject { instance.node }

    it { is_expected.to be_a(Openapi3Parser::Nodes::Map) }

    context "when input is expected to contain hashes" do
      let(:input) { { "a" => {}, "b" => 1 } }
      let(:value_input_type) { Hash }

      it "raises an InvalidType error" do
        error_type = Openapi3Parser::Error::InvalidType
        error_message = "Invalid type for #/b. Expected Hash"
        expect { instance.node }
          .to raise_error(error_type, error_message)
      end
    end
  end
end
