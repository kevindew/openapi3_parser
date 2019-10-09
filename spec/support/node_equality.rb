# frozen_string_literal: true

require "support/helpers/context"

RSpec.shared_examples "node equality" do |input|
  include Helpers::Context

  describe "#==" do
    let(:context) { create_node_context({}) }

    subject { described_class.new(input, context) }

    context "when context and input are the same" do
      let(:other) { described_class.new(input, context) }

      it { is_expected.to eq(other) }
    end

    context "when class, input and source locations match and document "\
      "location doesn't" do
      let(:other) do
        other_context = Openapi3Parser::Node::Context.new(
          {},
          document_location: Openapi3Parser::Source::Location.new(
            context.document_location.source,
            %w[different]
          ),
          source_location: context.source_location
        )

        described_class.new(input, other_context)
      end

      it { is_expected.to eq(other) }
    end

    context "when class differs" do
      let(:other) { Openapi3Parser::Node::Contact.new({}, context) }

      it { is_expected.not_to eq(other) }
    end

    context "when source is different" do
      let(:other) do
        other_context = Openapi3Parser::Node::Context.new(
          {},
          document_location: Openapi3Parser::Source::Location.new(
            context.document_location.source,
            %w[different]
          ),
          source_location: Openapi3Parser::Source::Location.new(
            context.document_location.source,
            %w[different]
          )
        )

        described_class.new(input, other_context)
      end

      it { is_expected.not_to eq(other) }
    end
  end
end
