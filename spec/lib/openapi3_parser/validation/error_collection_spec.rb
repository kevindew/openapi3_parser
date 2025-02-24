# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validation::ErrorCollection do
  let(:base_document) do
    source_input = Openapi3Parser::SourceInput::Raw.new({ "openapi" => "3.0.0" })
    Openapi3Parser::Document.new(source_input)
  end

  def create_error(message,
                   pointer_segments: [],
                   document: nil,
                   factory_class: nil)
    node_factory_context = create_node_factory_context(
      {},
      pointer_segments:,
      document:
    )
    Openapi3Parser::Validation::Error.new(message,
                                          node_factory_context,
                                          factory_class)
  end

  describe ".combine" do
    it "can combine collections of errors" do
      collection_of_errors = described_class.new([create_error("Error A")])
      array_of_errors = [create_error("Error B")]
      instance = described_class.combine(collection_of_errors, array_of_errors)
      expect(instance.errors)
        .to match_array(collection_of_errors.errors + array_of_errors)
    end
  end

  describe "#errors" do
    it "returns a frozen array of errors" do
      errors = [create_error("Boom")]
      instance = described_class.new(errors)

      expect(instance.errors)
        .to match_array(errors)
        .and be_frozen
    end
  end

  describe "#empty?" do
    it "returns true for no errors" do
      expect(described_class.new).to be_empty
    end

    it "returns false for any errors" do
      instance = described_class.new([create_error("error")])
      expect(instance).not_to be_empty
    end
  end

  describe "#group_errors" do
    it "returns an array of LocationTypeGroup objects" do
      grouped_errors = described_class.new([create_error("Boom")])
                                      .group_errors
      expect(grouped_errors)
        .to be_an(Array)
        .and all(be_an(Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup))
    end

    it "groups together errors of the same source location and type" do
      error_a = create_error("a", pointer_segments: %w[a], document: base_document)
      error_b = create_error("b", pointer_segments: %w[a], document: base_document)
      error_c = create_error("c", pointer_segments: %w[b], document: base_document)
      error_d = create_error("d",
                             pointer_segments: %w[a],
                             document: base_document,
                             factory_class: Openapi3Parser::NodeFactory::Contact)
      error_e = create_error("e",
                             pointer_segments: %w[a],
                             document: base_document,
                             factory_class: Openapi3Parser::NodeFactory::Info)

      instance = described_class.new([error_a,
                                      error_b,
                                      error_c,
                                      error_d,
                                      error_e])

      group_class = Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup

      expected = [
        group_class.new(error_a.context.source_location, nil, [error_a, error_b]),
        group_class.new(error_c.context.source_location, nil, [error_c]),
        group_class.new(error_d.context.source_location, "Contact", [error_d]),
        group_class.new(error_e.context.source_location, "Info", [error_e])
      ]
      expect(instance.group_errors).to match_array(expected)
    end
  end

  describe "#to_h" do
    it "returns a hash of errors with a source location key and an array of error strings" do
      error_a = create_error("Error A", pointer_segments: %w[a], document: base_document)
      error_b = create_error("Error B", pointer_segments: %w[a], document: base_document)
      error_c = create_error("Error C", pointer_segments: %w[b], document: base_document)

      instance = described_class.new([error_a, error_b, error_c])

      expect(instance.to_h).to match(
        "#/a" => ["Error A", "Error B"],
        "#/b" => ["Error C"]
      )
    end

    it "references the factory type in the key when there are varying types" do
      error_a = create_error("Error A",
                             pointer_segments: %w[a],
                             document: base_document,
                             factory_class: Openapi3Parser::NodeFactory::Contact)
      error_b = create_error("Error B",
                             pointer_segments: %w[a],
                             document: base_document,
                             factory_class: Openapi3Parser::NodeFactory::Info)

      instance = described_class.new([error_a, error_b])

      expect(instance.to_h).to match(
        "#/a (as Contact)" => ["Error A"],
        "#/a (as Info)" => ["Error B"]
      )
    end
  end
end
