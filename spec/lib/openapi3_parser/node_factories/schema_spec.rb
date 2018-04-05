# frozen_string_literal: true

require "openapi3_parser/node_factories/schema"
require "openapi3_parser/node/schema"

require "support/default_field"
require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Schema do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Schema do
    let(:input) do
      {
        "allOf" => [
          { "$ref" => "#/components/schemas/Pet" },
          {
            "type" => "object",
            "properties" => {
              "bark" => { "type" => "string" }
            }
          }
        ]
      }
    end

    let(:document_input) do
      {
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "required" => %w[pet_type],
              "properties" => {
                "pet_type" => { "type" => "string" }
              },
              "discriminator" => {
                "propertyName" => "pet_type",
                "mapping" => { "cachorro" => "Dog" }
              }
            }
          }
        }
      }
    end

    let(:context) { create_context(input, document_input: document_input) }
  end

  describe "items" do
    subject { described_class.new(context) }
    let(:context) { create_context("type" => type, "items" => items) }

    context "when type is not array and items is not provided" do
      let(:type) { "string" }
      let(:items) { nil }
      it { is_expected.to be_valid }
    end

    context "when type is array and items is not provided" do
      let(:type) { "array" }
      let(:items) { nil }
      it do
        is_expected
          .to have_validation_error("#/")
          .with_message("items must be defined for a type of array")
      end
    end

    context "when type is array and items areprovided" do
      let(:type) { "array" }
      let(:items) { { "type" => "string" } }
      it { is_expected.to be_valid }
    end
  end

  it_behaves_like "default field", field: "nullable", defaults_to: false do
    let(:context) { create_context("nullable" => nullable) }
  end

  it_behaves_like "default field",
                  field: "readOnly", defaults_to: false, var_name: :read_only do
                    let(:context) { create_context("readOnly" => read_only) }
                  end

  it_behaves_like "default field",
                  field: "writeOnly", defaults_to: false,
                  var_name: :write_only do
                    let(:context) { create_context("writeOnly" => write_only) }
                  end

  it_behaves_like "default field",
                  field: "deprecated", defaults_to: false,
                  var_name: :deprecated do
                    let(:context) { create_context("deprecated" => deprecated) }
                  end
end
