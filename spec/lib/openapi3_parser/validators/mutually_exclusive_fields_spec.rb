# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validators::MutuallyExclusiveFields do
  include Helpers::Context

  describe ".call" do
    let(:context) { create_context({}) }
    let(:validatable) do
      Openapi3Parser::Validation::Validatable.new(
        double("factory", context: context)
      )
    end
    let(:mutually_exclusive_fields) { [] }
    let(:raise_on_invalid) { true }

    subject(:call) do
      described_class.call(
        validatable,
        mutually_exclusive_fields: mutually_exclusive_fields,
        raise_on_invalid: raise_on_invalid
      )
    end

    context "when the instance is valid" do
      it { is_expected.to be_nil }
    end

    context "when both fields are provided and required is false" do
      let(:mutually_exclusive_fields) do
        [OpenStruct.new(fields: %w[a b], required: false)]
      end

      let(:context) { create_context("a" => true, "b" => true) }

      it "raises an error" do
        expect { call }
          .to raise_error(
            Openapi3Parser::Error::UnexpectedFields,
            "Mutually exclusive fields for #/: a and b are mutually "\
            "exclusive fields"
          )
      end
    end

    context "when neither fields are provided and required is false" do
      let(:mutually_exclusive_fields) do
        [OpenStruct.new(fields: %w[a b], required: false)]
      end

      let(:context) { create_context({}) }

      it "doesn't raise an error" do
        expect { call }.not_to raise_error
      end
    end

    context "when neither fields are provided and required is true" do
      let(:mutually_exclusive_fields) do
        [OpenStruct.new(fields: %w[a b], required: true)]
      end

      let(:context) { create_context({}) }

      it "raises an error" do
        expect { call }
          .to raise_error(
            Openapi3Parser::Error::MissingFields,
            "Mutually exclusive fields for #/: One of a and b is required"
          )
      end
    end

    context "when it is invalid and raise_on_invalid is false" do
      let(:mutually_exclusive_fields) do
        [OpenStruct.new(fields: %w[a b], required: true)]
      end
      let(:raise_on_invalid) { false }
      let(:context) { create_context({}) }

      it "doesn't raise errors" do
        expect { call }.not_to raise_error
      end

      it "adds errors to validatable" do
        expect { call }
          .to change { validatable.errors.count }
          .from(0)
          .to(1)
      end
    end
  end
end
