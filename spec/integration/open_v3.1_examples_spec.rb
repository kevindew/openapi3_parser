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

  context "when using the schema dialects example" do
    let(:path) { File.join(__dir__, "..", "support", "examples", "v3.1", "schema-dialects-example.yaml") }

    it "is valid but outputs warnings" do
      expect { document.valid? }.to output.to_stderr
      expect(document).to be_valid
    end

    it "only warns once per dialect" do
      expect { document.warnings }.to output.to_stderr
    end

    it "defaults to using the the jsonSchemaDialect value" do
      expect { document.warnings }.to output.to_stderr
      expect(document.components.schemas["DefaultDialect"].json_schema_dialect)
        .to eq(document.json_schema_dialect)
    end

    it "can return the other schema dialects" do
      expect { document.warnings }.to output.to_stderr
      expect(document.components.schemas["DefinedDialect"].json_schema_dialect)
        .to eq("https://spec.openapis.org/oas/3.1/dialect/base")
      expect(document.components.schemas["CustomDialect1"].json_schema_dialect)
        .to eq("https://example.com/custom-dialect")
    end
  end

  context "when using the schema I created to demonstrate changes" do
    let(:path) { File.join(__dir__, "..", "support", "examples", "v3.1", "changes.yaml") }

    it "is a valid document" do
      expect(document).to be_valid
    end

    it "can access the version" do
      expect(document.openapi).to eq "3.1.0"
    end

    it "can access a referenced schema" do
      expect(document.components.schemas["DoubleReferencedSchema"].required)
        .to match_array(%w[id name])
      expect(document.components.schemas["DoubleReferencedSchema"].description)
        .to eq("My double referenced schema")
    end

    it "can parse and navigate a dependentRequired field" do
      schema = document.components.schemas["DependentRequired"]

      expect(schema.dependent_required).to be_a(Openapi3Parser::Node::Map)
      expect(schema.dependent_required.keys).to match_array(%w[credit_card])
      expect(schema.dependent_required["credit_card"]).to be_a(Openapi3Parser::Node::Array)
      expect(schema.dependent_required["credit_card"]).to match_array(%w[billing_address])
    end
  end
end
