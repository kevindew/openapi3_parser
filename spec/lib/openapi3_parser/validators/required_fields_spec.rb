# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validators::RequiredFields do
  include Helpers::Context

  describe ".call" do
    let(:node_factory_context) { create_node_factory_context({}) }
    let(:validatable) do
      Openapi3Parser::Validation::Validatable.new(
        double("factory", context: node_factory_context)
      )
    end
    let(:required_fields) { [] }
    let(:raise_on_invalid) { false }

    subject(:call) do
      described_class.call(validatable,
                           required_fields: required_fields,
                           raise_on_invalid: raise_on_invalid)
    end

    context "when the instance is valid" do
      it { is_expected.to be_nil }
    end

    context "when it is invalid and raise_on_invalid is false" do
      let(:raise_on_invalid) { false }
      let(:required_fields) { %w[field] }

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

    context "when it is invalid and raise_on_invalid is true" do
      let(:raise_on_invalid) { true }
      let(:required_fields) { %w[field] }

      it "raises an error" do
        expect { call }
          .to raise_error(
            Openapi3Parser::Error::MissingFields,
            "Missing required fields for #/: field"
          )
      end
    end
  end
end
