# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::TypeChecker do
  include Helpers::Context
  let(:context) { create_context(input) }
  let(:factory) { double("factory", context: context) }

  describe ".validate_type" do
    let(:validatable) { Openapi3Parser::Validation::Validatable.new(factory) }

    subject(:validate_type) do
      described_class.validate_type(validatable, type: type)
    end

    context "when the type is valid" do
      let(:type) { Hash }
      let(:input) { {} }
      it { is_expected.to be true }
    end

    context "when the input type is invalid" do
      let(:type) { Integer }
      let(:input) { "Blah" }
      it { is_expected.to be false }

      it "adds an error to validatable" do
        validate_type
        expect(validatable.errors).to include(
          Openapi3Parser::Validation::Error.new(
            "Invalid type. Expected Integer",
            context,
            factory.class
          )
        )
      end
    end
  end

  describe ".raise_on_invalid_type" do
    subject(:raise_on_invalid_type) do
      described_class.raise_on_invalid_type(context, type: type)
    end

    context "when the type is valid" do
      let(:type) { Hash }
      let(:input) { {} }
      it { is_expected.to be true }
    end

    context "when the input type is invalid" do
      let(:type) { Integer }
      let(:input) { "Blah" }

      it "raises an error" do
        error_class = Openapi3Parser::Error::InvalidType
        expect { raise_on_invalid_type }
          .to raise_error(error_class, "Invalid type for #/: Expected Integer")
      end
    end
  end

  describe ".validate_keys" do
    let(:validatable) { Openapi3Parser::Validation::Validatable.new(factory) }

    subject(:validate_keys) do
      described_class.validate_keys(validatable, type: type)
    end

    context "when the type is valid" do
      let(:type) { Integer }
      let(:input) { { 1 => "a" } }
      it { is_expected.to be true }
    end

    context "when the input type is invalid" do
      let(:type) { Integer }
      let(:input) { { "string" => "erm" } }
      it { is_expected.to be false }

      it "adds an error to validatable" do
        validate_keys
        expect(validatable.errors).to include(
          Openapi3Parser::Validation::Error.new(
            "Invalid keys. Expected keys to be of type Integer",
            context,
            factory.class
          )
        )
      end
    end
  end

  describe ".raise_on_invalid_keys" do
    subject(:raise_on_invalid_keys) do
      described_class.raise_on_invalid_keys(context, type: type)
    end

    context "when the type is valid" do
      let(:type) { Integer }
      let(:input) { { 1 => "a" } }
      it { is_expected.to be true }
    end

    context "when the input type is invalid" do
      let(:type) { Integer }
      let(:input) { { "string" => "erm" } }

      it "raises an error" do
        error_class = Openapi3Parser::Error::InvalidType
        error_message = "Invalid keys for #/: Expected keys to be of type "\
                        "Integer"
        expect { raise_on_invalid_keys }
          .to raise_error(error_class, error_message)
      end
    end
  end

  describe "when type is a boolean symbol" do
    let(:type) { :boolean }

    context "when input is true" do
      let(:input) { true }

      it "validates without error" do
        expect do
          described_class.raise_on_invalid_type(context, type: type)
        end.not_to raise_error
      end
    end

    context "when input is false" do
      let(:input) { false }

      it "validates without error" do
        expect do
          described_class.raise_on_invalid_type(context, type: type)
        end.not_to raise_error
      end
    end

    context "when input is something different" do
      let(:input) { "different" }

      it "doesn't validate" do
        error_class = Openapi3Parser::Error::InvalidType
        error_message = "Invalid type for #/: Expected Boolean"

        expect do
          described_class.raise_on_invalid_type(context, type: type)
        end.to raise_error(error_class, error_message)
      end
    end
  end

  describe "when type is a non class" do
    let(:type) { "odd" }
    let(:input) { "anything" }

    it "raises an error" do
      error_class = Openapi3Parser::Error::UnvalidatableType
      error_message = "Expected odd to be a Class not a String"

      expect do
        described_class.raise_on_invalid_type(context, type: type)
      end.to raise_error(error_class, error_message)
    end
  end
end
