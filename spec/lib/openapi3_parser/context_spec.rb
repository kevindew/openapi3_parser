# frozen_string_literal: true

require "openapi3_parser/context/location"
require "openapi3_parser/document"
require "openapi3_parser/node/contact"
require "openapi3_parser/source_input/raw"

require "support/helpers/context"
require "support/helpers/source_input"

RSpec.describe Openapi3Parser::Context do
  include Helpers::Context
  include Helpers::SourceInput

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

  describe "#location_summary" do
    subject do
      described_class.new({},
                          document_location: document_location,
                          source_location: source_location)
                     .location_summary
    end

    context "when source location and document location are the same" do
      let(:document_location) do
        create_context_location(create_raw_source_input,
                                pointer_segments: %w[path to field])
      end
      let(:source_location) { document_location }

      it { is_expected.to eq "#/path/to/field" }
    end

    context "when source location and document location are different" do
      let(:document_location) do
        source_input = create_file_source_input(path: "/file.yaml")
        create_context_location(source_input,
                                pointer_segments: %w[path to field])
      end
      let(:source_location) do
        source_input = create_file_source_input(path: "/other-file.yaml")
        create_context_location(source_input,
                                document: document_location.source.document,
                                pointer_segments: %w[path])
      end

      it { is_expected.to eq "#/path/to/field (other-file.yaml#/path)" }
    end
  end

  describe "#resolved_input" do
    subject(:resolved_input) do
      described_class.new({},
                          document_location: document_location,
                          is_reference: is_reference)
                     .resolved_input
    end

    let(:document_location) do
      input = { "openapi" => "3.0.0",
                "info" => { "title" => "Test",
                            "version" => "1.0" },
                "paths" => {},
                "components" => {
                  "schemas" => {
                    "a_reference" => {
                      "$ref" => "#/components/schemas/not_reference"
                    },
                    "not_reference" => { "type" => "object" }
                  }
                } }
      create_context_location(Openapi3Parser::SourceInput::Raw.new(input),
                              pointer_segments: pointer_segments)
    end

    context "when context is not a reference" do
      let(:is_reference) { false }
      let(:pointer_segments) { %w[components schemas not_reference type] }

      it "returns the data at that location" do
        expect(resolved_input).to be "object"
      end
    end

    context "when context is a reference" do
      let(:is_reference) { true }
      let(:pointer_segments) { %w[components schemas a_reference $ref] }

      it "returns the data of the referenced item" do
        expect(resolved_input).to match(a_hash_including("type" => "object"))
      end
    end
  end

  describe "#node" do
    subject(:node) do
      described_class.new({},
                          document_location: document_location,
                          is_reference: is_reference)
                     .node
    end

    let(:document_location) do
      input = { "openapi" => "3.0.0",
                "info" => { "title" => "Test",
                            "version" => "1.0" },
                "paths" => {},
                "components" => {
                  "schemas" => {
                    "a_reference" => {
                      "$ref" => "#/components/schemas/not_reference"
                    },
                    "not_reference" => { "type" => "object" }
                  }
                } }
      create_context_location(Openapi3Parser::SourceInput::Raw.new(input),
                              pointer_segments: pointer_segments)
    end

    context "when context is not a reference" do
      let(:is_reference) { false }
      let(:pointer_segments) { %w[components schemas not_reference type] }

      it "returns the data at that location" do
        expect(node).to be "object"
      end
    end

    context "when context is a reference" do
      let(:is_reference) { true }
      let(:pointer_segments) { %w[components schemas a_reference $ref] }

      it "returns the data at the parent item" do
        expect(node).to be_a(Openapi3Parser::Node::Schema)
      end
    end
  end
end
