# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open a document with unresolvable recursive references" do
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
          "A": { "$ref": "#/components/schemas/B" },
          "B": { "$ref": "#/components/schemas/C" },
          "C": { "$ref": "#/components/schemas/A" }
        }
      }
    }
  end

  it { is_expected.not_to be_valid }

  it "raises an error accessing an unresolvable node" do
    expect { document.components.schemas["A"] }
      .to raise_error(Openapi3Parser::Error::InvalidData)

    expect { document.components.schemas["B"] }
      .to raise_error(Openapi3Parser::Error::InvalidData)
  end
end
