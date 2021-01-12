# frozen_string_literal: true

RSpec.describe "Open a document with unresolvable recursive references" do
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
          "wrong-type-reference": { "$ref": 1 },
          "badly-formatted-reference": { "$ref": "my object" },
          "unresolvable-a": { "$ref": "#/components/schemas/unresolvable-b" },
          "unresolvable-b": { "$ref": "#/components/schemas/unresolvable-c" },
          "unresolvable-c": { "$ref": "#/components/schemas/unresolvable-a" },
          "missing-source": { "$ref": "http://bad-example.com/#/my-object" },
          "missing-pointer": { "$ref": "http://example.com/#/pointer" },
          "invalid-schema": { "$ref": "http://example.com/#/bad-schema" }
        }
      }
    }
  end

  let(:remote_input) do
    {
      "bad-schema": 1
    }
  end

  before do
    stub_request(:get, "http://example.com/")
      .to_return(body: remote_input.to_json)
    stub_request(:get, "http://bad-example.com")
      .to_return(body: {}.to_json, status: 404)
  end

  it "isn't a valid document" do
    expect(document).not_to be_valid
  end

  it "has a validation error for a wrong type reference" do
    pointer = "#/components/schemas/wrong-type-reference/%24ref"
    issue = "Expected String"
    expect(document).to have_validation_error(pointer, issue)

    expect { document.components.schemas["wrong-type-reference"] }
      .to raise_error(Openapi3Parser::Error::InvalidType,
                      "Invalid type for #{pointer}: #{issue}")
  end

  it "has a validation error for a badly formatted reference" do
    pointer = "#/components/schemas/badly-formatted-reference/%24ref"
    issue = "Could not parse as a URI"
    expect(document).to have_validation_error(pointer, issue)

    expect { document.components.schemas["badly-formatted-reference"] }
      .to raise_error(Openapi3Parser::Error::InvalidData,
                      "Invalid data for #{pointer}: #{issue}")
  end

  it "has validation errors for infinitely recursive references" do
    %w[a b c].each do |x|
      pointer = "#/components/schemas/unresolvable-#{x}/%24ref"
      issue = "Reference doesn't resolve to an object"
      expect(document).to have_validation_error(pointer, issue)

      expect { document.components.schemas["unresolvable-#{x}"] }
        .to raise_error(Openapi3Parser::Error::InvalidData,
                        "Invalid data for #{pointer}: #{issue}")
    end
  end

  it "has a validation error for a reference to an unresolvable source file" do
    pointer = "#/components/schemas/missing-source/%24ref"
    issue = "Failed to open source http://bad-example.com/"

    expect(document).to have_validation_error(pointer, issue)

    expect { document.components.schemas["missing-source"] }
      .to raise_error(Openapi3Parser::Error::InvalidData,
                      "Invalid data for #{pointer}: #{issue}")
  end

  it "has a validation error for a reference missing from a source file" do
    pointer = "#/components/schemas/missing-pointer/%24ref"
    issue = "#/pointer is not defined in source http://example.com/"

    expect(document).to have_validation_error(pointer, issue)

    expect { document.components.schemas["missing-pointer"] }
      .to raise_error(Openapi3Parser::Error::InvalidData,
                      "Invalid data for #{pointer}: #{issue}")
  end

  it "has a validation error for a reference to invalid data" do
    pointer = "#/components/schemas/invalid-schema/%24ref"
    issue = "http://example.com/#/bad-schema does not resolve to a valid object"

    expect(document).to have_validation_error(pointer, issue)

    expect { document.components.schemas["invalid-schema"] }
      .to raise_error(Openapi3Parser::Error::InvalidData,
                      "Invalid data for #{pointer}: #{issue}")
  end
end
