# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::Schema do
  include Helpers::Context

  describe "#name" do
    subject { described_class.new({}, node_context).name }

    context "when the schema source location is a group of schemas" do
      let(:node_context) do
        create_node_context({}, pointer_segments: %w[components schemas Pet])
      end

      it { is_expected.to eq "Pet" }
    end

    context "when the schema source location is not a group of schemas" do
      let(:node_context) do
        create_node_context(
          {},
          pointer_segments: %w[content application/json schema]
        )
      end

      it { is_expected.to be_nil }
    end
  end
end
