# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open a document with cross document references" do
  subject(:document) { Openapi3Parser.load(input) }

  let(:input) do
    {
      openapi: "3.0.0",
      info: {
        title: "Test Document",
        version: "1.0.0"
      },
      paths: {},
      components: {
        examples: {
          test: { "$ref": "http://example.com/#/test" }
        }
      }
    }
  end

  let(:remote_input) do
    {
      test: {
        summary: "A foo example",
        value: { foo: "bar" }
      }
    }
  end

  before do
    stub_request(:get, "http://example.com/")
      .to_return(body: remote_input.to_json)
  end

  it { is_expected.to be_valid }
  it "can access the summary" do
    expect(document.components.examples["test"].summary).to eq "A foo example"
  end
end
