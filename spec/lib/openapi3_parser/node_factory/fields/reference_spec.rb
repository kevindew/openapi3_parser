# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Fields::Reference do
  include Helpers::Context

  describe "#resolved_input" do
    let(:factory) { Openapi3Parser::NodeFactory::Contact }
    subject(:resolved_input) do
      described_class.new(context, factory).resolved_input
    end

    let(:reference_context) do
      create_context("#/reference",
                     pointer_segments: reference_pointer,
                     document_input: {
                       "reference" => { "name" => "Joe" }
                     },
                     is_reference: true)
    end

    let(:context) do
      create_context("#/reference",
                     pointer_segments: context_pointer,
                     document: reference_context.document,
                     referenced_by: reference_context)
    end

    context "when not in a recursive loop" do
      let(:context_pointer) { %w[reference $ref] }
      let(:reference_pointer) { %w[other $ref] }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to match(hash_including("name" => "Joe")) }
    end

    context "when in a recursive loop" do
      let(:context_pointer) { %w[reference $ref] }
      let(:reference_pointer) { context_pointer }

      it do
        is_expected.to be_a(
          Openapi3Parser::NodeFactory::Fields::Reference::RecursiveResolvedInput
        )
      end

      it "can access the resolved data" do
        expect(resolved_input["name"]).to eq "Joe"
      end
    end
  end

  describe "in_recursive_loop?" do
    let(:factory) { Openapi3Parser::NodeFactory::Contact }
    subject { described_class.new(context, factory).in_recursive_loop? }

    context "when context is not a reference" do
      let(:context) { create_context("#/reference") }

      it { is_expected.to be false }
    end

    context "when context is referenced by the same pointer" do
      let(:reference_context) do
        create_context("#/item", pointer_segments: %w[reference $ref])
      end

      let(:context) do
        create_context("#/item",
                       pointer_segments: %w[reference $ref],
                       document: reference_context.document,
                       referenced_by: reference_context)
      end

      it { is_expected.to be true }
    end

    context "when context is referenced by a different pointer" do
      let(:reference_context) do
        create_context("#/item", pointer_segments: %w[other $ref])
      end

      let(:context) do
        create_context("#/item",
                       pointer_segments: %w[reference $ref],
                       document: reference_context.document,
                       referenced_by: reference_context)
      end

      it { is_expected.to be false }
    end
  end
end
