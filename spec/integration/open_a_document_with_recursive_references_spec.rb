# frozen_string_literal: true

require "openapi3_parser"
require "openapi3_parser/error"
require "openapi3_parser/node/schema"

RSpec.describe "Open a document with recursive references" do
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
        schemas: {
          "RecursiveItem": {
            type: "object",
            properties: {
              links: {
                type: "array",
                items: { "$ref": "#/components/schemas/RecursiveItem" }
              }
            }
          }
        }
      }
    }
  end

  it { is_expected.to be_valid }

  it "doesn't raise an error accessing the root" do
    expect { document.root }.not_to raise_error
  end

  it "returns the expected node class for the recursive item" do
    node = document.components
                   .schemas["RecursiveItem"]
                   .properties["links"]
                   .items
                   .properties["links"]
                   .items
    expect(node).to be_a(Openapi3Parser::Node::Schema)
  end
end
