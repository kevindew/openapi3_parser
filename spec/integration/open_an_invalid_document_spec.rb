# frozen_string_literal: true

RSpec.describe "Open an invalid document" do
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
          test: { extra: "field" }
        }
      }
    }
  end

  it "isn't a valid document" do
    expect(document).not_to be_valid
  end

  it "raises an exception accessing the erroneous node" do
    expect { document.openapi }.not_to raise_error
    expect { document.components.examples["test"] }
      .to raise_error(Openapi3Parser::Error)
  end
end
