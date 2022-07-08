# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Discriminator do
  it_behaves_like "node object factory", Openapi3Parser::Node::Discriminator do
    let(:input) do
      {
        "propertyName" => "test",
        "mapping" => { "key" => "value" }
      }
    end
  end

  describe "allow extensions" do
    it "accepts extensions for OpenAPI 3.1" do
      factory_context = create_node_factory_context(
        {
          "propertyName" => "test",
          "x-extension" => "value"
        },
        document_input: { "openapi" => "3.1.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).to be_valid
    end

    it "rejects extensions for OpenAPI < 3.1" do
      factory_context = create_node_factory_context(
        {
          "propertyName" => "test",
          "x-extension" => "value"
        },
        document_input: { "openapi" => "3.0.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
    end
  end
end
