require "openapi_parser/nodes/components"
require "openapi_parser/context"
require "openapi_parser/document"
require "openapi_parser/error"

RSpec.describe OpenapiParser::Nodes::Components do

  let(:schema_input) do
    {
      "field" => { "title" => "Test" }
    }
  end

  let(:input) do
    {
      "schemas" => schema_input
    }
  end

  let(:document_input) do
    {
      "components" => input
    }
  end

  let(:context) { OpenapiParser::Context.root(document) }
  let(:document) { OpenapiParser::Document.new(document_input) }

  describe ".schemas" do
    subject(:schemas) { described_class.new(input, context).schemas }

    context "when input is nil" do
      let(:schema_input) { nil }

      it { is_expected.to be_nil }
    end

    context "when input is not a hash" do
      let(:schema_input) { "not a hash" }

      it "raises an error" do
        expect {
          described_class.new(input, context).schemas
        }.to raise_error(OpenapiParser::Error)
      end
    end

    context "when input is a hash of schemas" do
      let(:schema_input) do
        {
          "field" => { "title" => "Test" }
        }
      end

      it "is a hash of schema objects" do
        expect(schemas).to match(a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Schema)
        ))
      end
    end

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

      it "is a hash of schema objects" do
        expect(schemas).to match(a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Schema)
        ))
      end
    end
  end
end
