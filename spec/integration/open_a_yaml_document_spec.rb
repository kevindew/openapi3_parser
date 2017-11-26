# frozen_string_literal: true

require "openapi3_parser"

RSpec.describe "Open a YAML Document" do
  let(:path) { File.join(__dir__, "..", "support", "examples", "uber.yaml") }
  subject(:document) { Openapi3Parser.load_file(path) }

  it { is_expected.to be_valid }

  it "can access the version" do
    expect(document.openapi).to eq "3.0.0"
  end

  it "can access the summary of the products path" do
    summary = document.paths["/products"].get.summary
    expect(summary).to eq "Product Types"
  end
end
