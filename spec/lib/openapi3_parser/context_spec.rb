# frozen_string_literal: true

require "openapi3_parser/context/location"
require "openapi3_parser/document"
require "openapi3_parser/source_input/raw"

require "support/helpers/context"

RSpec.describe Openapi3Parser::Context do
  include Helpers::Context

  describe ".root" do
    subject(:context) { described_class.root(input, source) }

    let(:input) { {} }
    let(:source) do
      source_input = Openapi3Parser::SourceInput::Raw.new(input)
      document = Openapi3Parser::Document.new(source_input)
      document.root_source
    end

    it "has no reference" do
      expect(context.referenced_by).to be_nil
    end

    it "has an empty pointer" do
      expect(context.document_location.pointer.to_s).to eq "#/"
    end
  end

  describe ".next_field" do
    subject(:context) { described_class.next_field(parent_context, field) }
    let(:input) { { "key" => "value" } }
    let(:parent_context) do
      create_context(input, document_input: input, pointer_segments: [])
    end
    let(:field) { "key" }

    it "has an input of 'value'" do
      expect(context.input).to eq "value"
    end

    it "has a pointer fragment of '#/key'" do
      expect(context.document_location.pointer.to_s).to eq "#/key"
    end
  end

  describe ".reference_field" do
    subject(:context) do
      described_class.reference_field(referencer_context,
                                      input: reference_input,
                                      source: source,
                                      pointer_segments: pointer_segments)
    end

    let(:referencer_context) do
      create_context({}, pointer_segments: %w[components schemas])
    end
    let(:reference_input) { { "from" => "reference" } }
    let(:source) do
      Openapi3Parser::Source.new(Openapi3Parser::SourceInput::Raw.new({}),
                                 referencer_context.document,
                                 referencer_context.document.root_source)
    end
    let(:pointer_segments) { %w[test pointer] }

    it "has the reference_input" do
      expect(context.input).to eq reference_input
    end

    it "is referenced by the previous context" do
      expect(context.referenced_by).to be referencer_context
    end

    it "has the same document location" do
      previous_location = referencer_context.document_location
      expect(context.document_location).to eq previous_location
    end

    it "has a source location for the reference" do
      reference_source_location = Openapi3Parser::Context::Location.new(
        source,
        pointer_segments
      )
      expect(context.source_location).to eq reference_source_location
    end
  end
end
