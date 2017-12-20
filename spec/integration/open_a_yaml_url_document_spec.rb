# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open a YAML Document via URL" do
  before do
    path = File.join(
      __dir__, "..", "support", "examples", "petstore-expanded.yaml"
    )
    stub_request(:get, "example.com/openapi.yml")
      .to_return(body: File.open(path).read)
  end

  let(:url) { "http://example.com/openapi.yml" }
  subject(:document) { Openapi3Parser.load_url(url) }

  it { is_expected.to be_valid }

  it "can access the version" do
    expect(document.openapi).to eq "3.0.0"
  end

  it "can access the summary of the products path" do
    operation_id = document.paths["/pets"].get.operation_id
    expect(operation_id).to eq "findPets"
  end
end
