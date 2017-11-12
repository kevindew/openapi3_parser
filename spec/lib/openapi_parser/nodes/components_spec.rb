# frozen_string_literal: true

require "openapi_parser/nodes/components"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/response"
require "openapi_parser/nodes/parameter"
require "openapi_parser/nodes/example"
require "openapi_parser/context"
require "openapi_parser/document"
require "openapi_parser/error"

require "support/extendable_node"
require "support/node_field"

RSpec.describe OpenapiParser::Nodes::Components do
  let(:schemas_input) do
    {
      "field" => { "title" => "Test" }
    }
  end

  let(:responses_input) do
    {
      "field" => { "description" => "Test" }
    }
  end

  let(:parameters_input) do
    {
      "field" => { "name" => "test", "in" => "query" }
    }
  end

  let(:examples_input) do
    {
      "field" => { "summary" => "My Summary" }
    }
  end

  let(:input) do
    {
      "schemas" => schemas_input,
      "responses" => responses_input,
      "parameters" => parameters_input,
      "examples" => examples_input
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
                     invalid_input: "not a hash"

    context "when input is a hash with references" do
      let(:schemas_input) do
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

    it "returns a hash of Schema objects" do
      expect(schemas).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Schema)
        )
      )
    end
  end

  describe "responses field" do
    include_examples "node field", "responses",
                     required: false,
                     valid_input: { "field" => { "description" => "Test" } },
                     invalid_input: "not a hash"

    context "when input is a hash with references" do
      let(:responses_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "components" => input,
          "reference" => { "description" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".responses" do
    subject(:responses) { described_class.new(input, context).responses }

    it "returns a hash of Response objects" do
      expect(responses).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Response)
        )
      )
    end
  end

  describe "parameters field" do
    include_examples "node field", "parameters",
                     required: false,
                     valid_input: {
                       "field" => { "name" => "test", "in" => "query" }
                     },
                     invalid_input: "not a hash"

    context "when input is a hash with references" do
      let(:parameters_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "components" => input,
          "reference" => { "name" => "test", "in" => "query" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".parameters" do
    subject(:parameters) { described_class.new(input, context).parameters }

    it "returns a hash of Parameter objects" do
      expect(parameters).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Parameter)
        )
      )
    end
  end

  describe "examples field" do
    include_examples "node field", "examples",
                     required: false,
                     valid_input: {
                       "field" => { "summary" => "My summary" }
                     },
                     invalid_input: "not a hash"

    context "when input is a hash with references" do
      let(:examples_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "components" => input,
          "reference" => { "summary" => "My summary" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".examples" do
    subject(:examples) { described_class.new(input, context).examples }

    it "returns a hash of Example objects" do
      expect(examples).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Example)
        )
      )
    end
  end
end
