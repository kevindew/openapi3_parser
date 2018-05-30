# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/validation/validatable"
require "openapi3_parser/validators/unexpected_fields"

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validators::UnexpectedFields do
  include Helpers::Context

  describe ".call" do
    let(:context) { create_context({}) }
    let(:validatable) do
      Openapi3Parser::Validation::Validatable.new(
        Openapi3Parser::NodeFactory::Map.new(context)
      )
    end
    let(:allow_extensions) { true }
    let(:allowed_fields) { nil }
    let(:raise_on_invalid) { true }

    subject(:call) do
      described_class.call(validatable,
                           allow_extensions: allow_extensions,
                           allowed_fields: allowed_fields,
                           raise_on_invalid: raise_on_invalid)
    end

    context "when the instance is valid" do
      it { is_expected.to be_nil }
    end

    describe "allow_extensions option" do
      let(:context) do
        create_context(
          "x-extension" => "my extension",
          "x-extension-2" => "my other extension"
        )
      end

      context "when it is true" do
        let(:allow_extensions) { true }
        it "doesn't raise error on extensions" do
          expect { call }.not_to raise_error
        end
      end

      context "when it is false" do
        let(:allow_extensions) { false }
        it "raises an error on extensions" do
          expect { call }
            .to raise_error(
              Openapi3Parser::Error::UnexpectedFields,
              "Unexpected fields for #/: x-extension and x-extension-2"
            )
        end
      end
    end

    describe "allowed_fields option" do
      let(:context) { create_context("fieldA" => "My field") }

      context "when it includes the fields" do
        let(:allowed_fields) { %w[fieldA fieldB] }
        it "doesn't raise error" do
          expect { call }.not_to raise_error
        end
      end

      context "when it is nil" do
        let(:allowed_fields) { nil }
        it "doesn't raise error" do
          expect { call }.not_to raise_error
        end
      end

      context "when it doesn't include the fields" do
        let(:allowed_fields) { %w[fieldB fieldC] }
        it "raises an error on extensions" do
          expect { call }
            .to raise_error(
              Openapi3Parser::Error::UnexpectedFields,
              "Unexpected fields for #/: fieldA"
            )
        end
      end

      context "when it includes extesnions and they're allowed" do
        let(:context) do
          create_context("fieldA" => "My field", "x-test" => "my extension")
        end
        let(:allowed_fields) { %w[fieldA] }
        let(:allowed_extensions) { true }
        it "raises an error on extensions" do
          expect { call }.not_to raise_error
        end
      end
    end

    describe "raise_on_invalid option" do
      let(:context) { create_context("fieldA" => "My field") }
      let(:allowed_fields) { %w[fieldB] }

      context "when it is false" do
        let(:raise_on_invalid) { false }

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
end
