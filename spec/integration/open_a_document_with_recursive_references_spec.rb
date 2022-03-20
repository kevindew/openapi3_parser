# frozen_string_literal: true

RSpec.describe "Open a document with recursive references" do
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
        schemas: {
          RecursiveItem: {
            type: "object",
            properties: {
              links: {
                type: "array",
                items: { "$ref": "#/components/schemas/RecursiveItem" }
              },
              directly_recursive: {
                "$ref": "#/components/schemas/RecursiveItem"
              },
              indirectly_recursive: {
                "$ref": "#/components/schemas/IndirectlyRecursiveItem"
              }
            }
          },
          IndirectlyRecursiveItem: {
            type: "object",
            properties: {
              recursive_item: { "$ref": "#/components/schemas/RecursiveItem" }
            }
          },
          RecursiveArray: {
            oneOf: [
              { "$ref": "#/components/schemas/RecursiveArray" },
              { "$ref": "#/components/schemas/RecursiveItem" },
              { "$ref": "#/components/schemas/IndirectlyRecursiveItem" }
            ]
          }
        }
      }
    }
  end

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "doesn't raise an error accessing the root" do
    expect { document.root }.not_to raise_error
  end

  it "returns the expected node class for a recursive object" do
    node = document.components
                   .schemas["RecursiveItem"]
                   .properties["links"]
                   .items
                   .properties["links"]
                   .items
    expect(node).to be_a(Openapi3Parser::Node::Schema::V3_0)
  end

  it "returns the expected node class for a directly recursive property" do
    node = document.components
                   .schemas["RecursiveItem"]
                   .properties["directly_recursive"]
                   .properties["directly_recursive"]
    expect(node).to be_a(Openapi3Parser::Node::Schema::V3_0)
  end

  it "returns the expected node class for an indirectly recursive property" do
    node = document.components
                   .schemas["RecursiveItem"]
                   .properties["indirectly_recursive"]
                   .properties["recursive_item"]
    expect(node).to be_a(Openapi3Parser::Node::Schema::V3_0)
  end

  it "returns the expected node class for a recursive item in an array" do
    node = document.components
                   .schemas["RecursiveArray"]
                   .one_of[0]
    expect(node).to be_a(Openapi3Parser::Node::Schema::V3_0)
  end
end
