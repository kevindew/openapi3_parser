# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::License do
  let(:minimal_license_definition) { { "name" => "License" } }

  it_behaves_like "node object factory", Openapi3Parser::Node::License do
    let(:input) { minimal_license_definition }
  end

  describe "validating URL" do
    it "is valid for an actual URL" do
      factory_context = create_node_factory_context(
        minimal_license_definition.merge({ "url" => "https://example.com/path" })
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an incorrect URL" do
      factory_context = create_node_factory_context(
        minimal_license_definition.merge({ "url" => "not a url" })
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/url")
    end
  end

  describe "identifier field" do
    it "accepts an identifier field for OpenAPI >= v3.1" do
      factory_context = create_node_factory_context(
        minimal_license_definition.merge({ "identifier" => "Apache-2.0" }),
        document_input: { "openapi" => "3.1.0" }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "rejects an identifier field for OpenAPI < v3.1" do
      factory_context = create_node_factory_context(
        minimal_license_definition.merge({ "identifier" => "Apache-2.0" }),
        document_input: { "openapi" => "3.0.0" }
      )
      instance = described_class.new(factory_context)

      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/").with_message("Unexpected fields: identifier")
    end

    it "rejects both a license and a url field (mutually exclusive)" do
      factory_context = create_node_factory_context(
        minimal_license_definition.merge({
                                           "identifier" => "Apache-2.0",
                                           "url" => "https://example.com/url"
                                         }),
        document_input: { "openapi" => "3.1.0" }
      )
      instance = described_class.new(factory_context)

      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/").with_message("identifier and url are mutually exclusive fields")
    end
  end
end
