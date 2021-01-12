# frozen_string_literal: true

require "support/helpers/context"

RSpec.shared_examples "node equality" do |input|
  include Helpers::Context

  describe "#==" do
    let(:context) { create_node_context({}) }

    it "is equal when context and input are the same" do
      instance = described_class.new(input, context)
      other = described_class.new(input, context)
      expect(instance).to eq(other)
    end

    it "is equal when class, input and source locations match but document location doesn't" do
      instance = described_class.new(input, context)
      other_context = Openapi3Parser::Node::Context.new(
        {},
        document_location: Openapi3Parser::Source::Location.new(
          context.document_location.source,
          %w[different]
        ),
        source_location: context.source_location
      )
      other = described_class.new(input, other_context)
      expect(instance).to eq(other)
    end

    it "isn't equal when the class differs" do
      instance = described_class.new(input, context)
      other = Openapi3Parser::Node::Contact.new({}, context)
      expect(instance).not_to eq(other)
    end

    it "isn't equal when source is different" do
      instance = described_class.new(input, context)
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

      other = described_class.new(input, other_context)
      expect(instance).not_to eq(other)
    end
  end
end
