# frozen_string_literal: true

RSpec.describe "Open a document with cross document references" do
  let(:document) { Openapi3Parser.load(input) }

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

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "can access the summary" do
    expect(document.components.examples["test"].summary).to eq "A foo example"
  end
end
