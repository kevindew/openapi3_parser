# frozen_string_literal: true

require "openapi_parser/nodes/response"
require "openapi_parser/nodes/header"
require "openapi_parser/nodes/media_type"
require "openapi_parser/nodes/link"
require "openapi_parser/context"
require "openapi_parser/document"

require "support/node_field"
require "support/extendable_node"

RSpec.describe OpenapiParser::Nodes::Response do
  let(:description_input) { "A response" }
  let(:headers_input) { nil }
  let(:content_input) { nil }
  let(:links_input) { nil }

  let(:input) do
    {
      "description" => description_input,
      "headers" => headers_input,
      "content" => content_input,
      "links" => links_input
    }.merge(extensions)
  end

  let(:extensions) { {} }

  let(:document) { OpenapiParser::Document.new(document_input) }
  let(:context) { OpenapiParser::Context.root(document) }
  let(:document_input) { {} }

  it "initializes with valid input" do
    expect { described_class.new(input, context) }.to_not raise_error
  end

  it_behaves_like "a extendable node"

  describe "description field" do
    include_examples "node field", "description",
                     required: true,
                     valid_input: "A String",
                     invalid_input: 123
  end

  describe ".description" do
    let(:description_input) { "A response" }
    subject { described_class.new(input, context).description }
    it { is_expected.to be description_input }
  end

  describe "headers field" do
    include_examples "node field", "headers",
                     required: false,
                     valid_input: { "key" => { "name" => "header" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:headers_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "name" => "Test" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".headers" do
    let(:headers_input) do
      {
        "field" => { "name" => "Header" }
      }
    end

    subject(:headers) { described_class.new(input, context).headers }

    it "returns a hash of Header objects" do
      expect(headers).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Header)
        )
      )
    end
  end

  describe "content field" do
    include_examples "node field", "content",
                     required: false,
                     valid_input: { "key" => { "example" => "Some text" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:content_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "example" => "Some text" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".content" do
    let(:content_input) do
      {
        "field" => { "example" => "Some text" }
      }
    end

    subject(:content) { described_class.new(input, context).content }

    it "returns a hash of MediaType objects" do
      expect(content).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::MediaType)
        )
      )
    end
  end

  describe "links field" do
    include_examples "node field", "links",
                     required: false,
                     valid_input: { "key" => { "operationId" => "anAction" } },
                     invalid_input: 123

    context "when input is a hash with references" do
      let(:links_input) do
        {
          "field" => { "$ref" => "#/reference" }
        }
      end

      let(:document_input) do
        {
          "reference" => { "operationId" => "anAction" }
        }
      end

      it "is expected not to raise an error" do
        expect { described_class.new(input, context) }.not_to raise_error
      end
    end
  end

  describe ".links" do
    let(:links_input) do
      {
        "field" => { "operationId" => "someOperation" }
      }
    end

    subject(:links) { described_class.new(input, context).links }

    it "returns a hash of Link objects" do
      expect(links).to match(
        a_hash_including(
          "field" => an_instance_of(OpenapiParser::Nodes::Link)
        )
      )
    end
  end
end
