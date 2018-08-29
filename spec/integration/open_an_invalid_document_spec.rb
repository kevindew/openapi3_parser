# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open an invalid document" do
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
          test: { extra: "field" }
        }
      }
    }
  end

  it { is_expected.to_not be_valid }

  it "raises an exception accessing the root" do
    expect { document.root }.to raise_error(Openapi3Parser::Error)
  end
end
