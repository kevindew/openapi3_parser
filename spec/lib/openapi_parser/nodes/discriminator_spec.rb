# frozen_string_literal: true

require "openapi_parser/nodes/discriminator"
require "openapi_parser/context"
require "openapi_parser/document"
require "openapi_parser/error"

RSpec.describe OpenapiParser::Nodes::Discriminator do
  let(:property_name_input) { "My Property" }
  let(:mapping_input) { nil }

  let(:input) do
    {
      "propertyName" => property_name_input,
      "mapping" => mapping_input
    }
  end

  let(:document) { instance_double("OpenapiParser::Document") }
  let(:context) { OpenapiParser::Context.root(document) }

  describe ".property_name" do
    subject(:property_name) { described_class.new(input, context).property_name }

    context "when input is nil" do
      let(:property_name_input) { nil }

      it "raises an error" do
        expect do
          described_class.new(input, context)
        end.to raise_error(OpenapiParser::Error)
      end
    end

    context "when input is not a string" do
      let(:property_name_input) { 123 }

      it "raises an error" do
        expect do
          described_class.new(input, context)
        end.to raise_error(OpenapiParser::Error)
      end
    end

    context "when input is a string" do
      let(:property_name_input) { "property_input" }

      it { is_expected.to eq property_name_input }
    end
  end

  describe ".mapping" do
    subject(:mapping) { described_class.new(input, context).mapping }

    context "when input is nil" do
      let(:mapping_input) { nil }

      it { is_expected.to match({}) }
    end

    context "when input is not a hash" do
      let(:mapping_input) { 123 }

      it "raises an error" do
        expect do
          described_class.new(input, context)
        end.to raise_error(OpenapiParser::Error)
      end
    end

    context "when input is a hash of strings" do
      let(:mapping_input) { { "test" => "test" } }

      it "doesn't raise an error" do
        expect do
          described_class.new(input, context)
        end.to_not raise_error
      end
    end
  end
end
