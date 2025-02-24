# frozen_string_literal: true

RSpec.describe "Open a YAML Document via URL" do
  let(:document) { Openapi3Parser.load_url(url) }
  let(:url) { "http://example.com/openapi.yml" }

  before do
    path = File.join(
      __dir__, "..", "support", "examples", "v3.0", "petstore-expanded.yaml"
    )
    stub_request(:get, "example.com/openapi.yml")
      .to_return(body: File.read(path))
  end

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "can access the version" do
    expect(document.openapi).to eq "3.0.0"
  end

  it "can access the summary of the products path" do
    operation_id = document.paths["/pets"].get.operation_id
    expect(operation_id).to eq "findPets"
  end
end
