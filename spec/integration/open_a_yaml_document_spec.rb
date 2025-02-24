# frozen_string_literal: true

RSpec.describe "Open a YAML Document" do
  let(:document) { Openapi3Parser.load_file(path) }
  let(:path) { File.join(__dir__, "..", "support", "examples", "v3.0", "uber.yaml") }

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "can access the version" do
    expect(document.openapi).to eq "3.0.0"
  end

  it "can access the summary of the products path" do
    summary = document.paths["/products"].get.summary
    expect(summary).to eq "Product Types"
  end
end
