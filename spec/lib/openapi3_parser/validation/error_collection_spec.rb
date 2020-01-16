# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validation::ErrorCollection do
  include Helpers::Context

  let(:base_document) do
    source_input = Openapi3Parser::SourceInput::Raw.new({})
    Openapi3Parser::Document.new(source_input)
  end

  def create_error(message,
                   pointer_segments: [],
                   document: nil,
                   factory_class: nil)
    node_factory_context = create_node_factory_context(
      {},
      pointer_segments: pointer_segments,
      document: document
    )
    Openapi3Parser::Validation::Error.new(message,
                                          node_factory_context,
                                          factory_class)
  end

  describe ".combine" do
    subject(:collection) { described_class.combine(errors_a, errors_b) }

    context "when there are two error collections" do
      let(:errors_a) { described_class.new([create_error("Error A")]) }
      let(:errors_b) { described_class.new([create_error("Error B")]) }

      it "has the same errors" do
        expect(collection.errors)
          .to match_array(errors_a.errors + errors_b.errors)
      end
    end

    context "when there are arrays of errors" do
      let(:errors_a) { [create_error("Error A")] }
      let(:errors_b) { [create_error("Error B")] }

      it "has the same errors" do
        expect(collection.errors)
          .to match_array(errors_a + errors_b)
      end
    end

    context "when there is an error collection and an array of errors" do
      let(:errors_a) { described_class.new([create_error("Error A")]) }
      let(:errors_b) { [create_error("Error B")] }

      it "has the same errors" do
        expect(collection.errors)
          .to match_array(errors_a.errors + errors_b)
      end
    end
  end

  describe "#errors" do
    subject { described_class.new(errors).errors }

    let(:errors) { [create_error("Boom")] }

    it { is_expected.to match_array(errors) }
    it { is_expected.to be_frozen }
  end

  describe "#empty?" do
    subject { described_class.new(errors).empty? }

    context "when there are errors" do
      let(:errors) { [create_error("Boom")] }
      it { is_expected.to be false }
    end

    context "when there are not errors" do
      let(:errors) { [] }
      it { is_expected.to be true }
    end
  end

  describe "#group_errors" do
    subject(:grouped_errors) { described_class.new(errors).group_errors }
    let(:errors) { [create_error("Boom")] }

    it "returns an array of LocationTypeGroup objects" do
      group_type = an_instance_of(
        Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup
      )
      expect(grouped_errors).to match_array([group_type])
    end

    context "when there are errors for different source locations" do
      let(:ut_oh) do
        create_error("Ut oh", pointer_segments: %w[a], document: base_document)
      end
      let(:darn) do
        create_error("Darn", pointer_segments: %w[b], document: base_document)
      end
      let(:errors) { [ut_oh, darn] }

      it "has a length of 2" do
        expect(grouped_errors.length).to eq 2
      end

      it "matches the location type groups" do
        klass = Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup
        expect(grouped_errors).to match_array(
          [
            klass.new(ut_oh.context.source_location, nil, [ut_oh]),
            klass.new(darn.context.source_location, nil, [darn])
          ]
        )
      end
    end

    context "when there are errors with same source locations" do
      let(:ut_oh) do
        create_error("Ut oh", pointer_segments: %w[a], document: base_document)
      end
      let(:darn) do
        create_error("Darn", pointer_segments: %w[a], document: base_document)
      end
      let(:errors) { [ut_oh, darn] }

      it "has a length of 1" do
        expect(grouped_errors.length).to eq 1
      end

      it "matches the location type groups" do
        klass = Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup
        expect(grouped_errors).to match_array(
          [
            klass.new(ut_oh.context.source_location, nil, [ut_oh, darn])
          ]
        )
      end
    end

    context "when errors have same source locations but are for different "\
            "factories" do
      class NodeFactory1; end
      class NodeFactory2; end

      let(:ut_oh) do
        create_error("Ut oh",
                     pointer_segments: %w[a],
                     document: base_document,
                     factory_class: NodeFactory1)
      end

      let(:darn) do
        create_error("Darn",
                     pointer_segments: %w[a],
                     document: base_document,
                     factory_class: NodeFactory2)
      end

      let(:errors) { [ut_oh, darn] }

      it "has a length of 2" do
        expect(grouped_errors.length).to eq 2
      end

      it "matches the location type groups" do
        klass = Openapi3Parser::Validation::ErrorCollection::LocationTypeGroup
        expect(grouped_errors).to match_array(
          [
            klass.new(ut_oh.context.source_location, "NodeFactory1", [ut_oh]),
            klass.new(darn.context.source_location, "NodeFactory2", [darn])
          ]
        )
      end
    end

    context "when there are no errors" do
      let(:errors) { [] }
      it { is_expected.to be_empty }
    end
  end

  describe "#to_h" do
    subject(:errors_hash) { described_class.new(errors).to_h }
    let(:errors) { [create_error("Boom")] }

    it "returns a hash" do
      expect(errors_hash).to be_an_instance_of(Hash)
    end

    context "when there are errors for different source locations" do
      let(:ut_oh) do
        create_error("Ut oh", pointer_segments: %w[a], document: base_document)
      end
      let(:darn) do
        create_error("Darn", pointer_segments: %w[b], document: base_document)
      end
      let(:errors) { [ut_oh, darn] }

      it "has both errors" do
        expect(errors_hash).to match(
          "#/a" => ["Ut oh"],
          "#/b" => ["Darn"]
        )
      end
    end

    context "when there are errors with same source locations" do
      let(:ut_oh) do
        create_error("Ut oh", pointer_segments: %w[a], document: base_document)
      end
      let(:darn) do
        create_error("Darn", pointer_segments: %w[a], document: base_document)
      end
      let(:errors) { [ut_oh, darn] }

      it "groups the errors" do
        expect(errors_hash).to match(
          "#/a" => ["Ut oh", "Darn"]
        )
      end
    end

    context "when errors have same source locations but are for different "\
            "factories" do
      class NodeFactory1; end
      class NodeFactory2; end

      let(:ut_oh) do
        create_error("Ut oh",
                     pointer_segments: %w[a],
                     document: base_document,
                     factory_class: NodeFactory1)
      end

      let(:darn) do
        create_error("Darn",
                     pointer_segments: %w[a],
                     document: base_document,
                     factory_class: NodeFactory2)
      end

      let(:another) do
        create_error("Another",
                     pointer_segments: %w[b],
                     document: base_document,
                     factory_class: NodeFactory1)
      end

      let(:errors) { [ut_oh, darn, another] }

      it "has the errors with type when there is ambiguity" do
        expect(errors_hash).to match(
          "#/a (as NodeFactory1)" => ["Ut oh"],
          "#/a (as NodeFactory2)" => ["Darn"],
          "#/b" => ["Another"]
        )
      end
    end

    context "when there are no errors" do
      let(:errors) { [] }
      it { is_expected.to be_empty }
    end
  end
end
