# frozen_string_literal: true

require "openapi3_parser/validation/error"
require "openapi3_parser/validation/error_collection"

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validation::ErrorCollection do
  include Helpers::Context

  def create_error(message)
    Openapi3Parser::Validation::Error.new(message, create_context({}))
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
end
