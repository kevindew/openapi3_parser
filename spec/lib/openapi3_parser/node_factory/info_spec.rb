# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Info do
  let(:minimal_info_definition) do
    {
      "title" => "Info",
      "version" => "1.0"
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Info do
    let(:input) do
      minimal_info_definition.merge(
        "license" => { "name" => "License" },
        "contact" => { "name" => "Contact" }
      )
    end
  end

  describe "validating terms of service URL" do
    it "is valid for an actual URL" do
      factory_context = create_node_factory_context(
        minimal_info_definition.merge({ "termsOfService" => "https://example.com/path" })
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an incorrect URL" do
      factory_context = create_node_factory_context(
        minimal_info_definition.merge({ "termsOfService" => "not a url" })
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/termsOfService")
    end
  end

  describe "summary field" do
    it "accepts a summary field for OpenAPI >= v3.1" do
      factory_context = create_node_factory_context(
        minimal_info_definition.merge({ "summary" => "summary contents" }),
        document_input: { "openapi" => "3.1.0" }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "rejects a summary field for OpenAPI < v3.1" do
      factory_context = create_node_factory_context(
        minimal_info_definition.merge({ "summary" => "summary contents" }),
        document_input: { "openapi" => "3.0.0" }
      )
      instance = described_class.new(factory_context)

      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/").with_message("Unexpected fields: summary")
    end
  end
end
