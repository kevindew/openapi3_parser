# frozen_string_literal: true

RSpec.describe "Open v3.1 examples" do
  let(:document) { Openapi3Parser.load_url(url) }
  let(:url) { "http://example.com/openapi.yml" }

  before do
    stub_request(:get, "example.com/openapi.yml")
      .to_return(body: File.read(path))
  end

  context "when using the webhook example" do
    let(:path) { File.join(__dir__, "..", "support", "examples", "v3.1", "webhook-example.yaml") }

    it "is a valid document" do
      expect(document).to be_valid
    end

    it "can access the version" do
      expect(document.openapi).to eq "3.1.0"
    end
  end

  context "when using the non-oauth scope example" do
    let(:path) { File.join(__dir__, "..", "support", "examples", "v3.1", "non-oauth-scopes.yaml") }

    it "is a valid document" do
      expect(document).to be_valid
    end

    it "can access the version" do
      expect(document.openapi).to eq "3.1.0"
    end
  end
end
