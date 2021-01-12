# frozen_string_literal: true

RSpec.describe "Open a document with defaults" do
  let(:document) { Openapi3Parser.load(input) }

  let(:input) do
    {
      openapi: "3.0.0",
      info: {
        title: "Test Document",
        version: "1.0.0"
      },
      paths: {
        "/path": {
          get: {
            responses: {
              default: {
                description: "Get response",
                content: {
                  "application/json": {
                    example: "test"
                  }
                }
              }
            }
          }
        }
      },
      components: {
        schemas: {
          my_schema: {
            title: "My Schema"
          }
        }
      }
    }
  end

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "has nil values for objects without defaults" do
    expect(document.info.contact).to be_nil
  end

  it "has nil values for arrays that don't need a value" do
    expect(document.components.schemas["my_schema"].required).to be_nil
  end

  it "has nil values for objects that default to nil" do
    media_type = document.paths["/path"]
                         .get
                         .responses["default"]
                         .content["application/json"]
    expect(media_type.examples).to be_nil
  end
end
