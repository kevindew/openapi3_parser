# frozen_string_literal: true

require "openapi_parser/nodes/components"
require "openapi_parser/context"
require "openapi_parser/document"
require "openapi_parser/error"

require "support/extendable_node"
require "support/node_field"

RSpec.describe OpenapiParser::Nodes::Components do
  let(:schema_input) do
    {
      "field" => { "title" => "Test" }
    }
  end

  let(:input) do
    {
      "schemas" => schema_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document_input) do
    {
      "components" => input
    }
  end

  let(:context) { OpenapiParser::Context.root(document) }
  let(:document) { OpenapiParser::Document.new(document_input) }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "schemas field" do
    include_examples "node field", "schemas",
                     required: false,
                     valid_input: { "field" => { "title" => "Test" } },
                     invalid_input: "not a hash",
                     let_name: :schema_input

    context "when input is a hash with references" do
      let(:schema_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "components" => input,
          "reference" => { "title" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".schemas" do
    subject(:schemas) { described_class.new(input, context).schemas }

    it "returns a hash of Schema Objects" do
      expect(schemas).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Schema)
        )
      )
    end
  end
end
