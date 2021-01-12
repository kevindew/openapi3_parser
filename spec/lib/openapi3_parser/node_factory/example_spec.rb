# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Example do
  it_behaves_like "node object factory", Openapi3Parser::Node::Example do
    let(:input) do
      {
        "summary" => "Summary",
        "value" => [1, 2, 3],
        "x-otherField" => "Extension value"
      }
    end
  end

  describe "validating externalValue formatting" do
    it "is valid for an actual URL" do
      factory_context = create_node_factory_context(
        { "externalValue" => "https://example.com/path" }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an incorrect URL" do
      factory_context = create_node_factory_context(
        { "externalValue" => "not a url" }
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/externalValue")
    end
  end

  describe "validating value and externalValue are mutually exclusive" do
    it "is valid when neither are provided" do
      expect(described_class.new(create_node_factory_context({})))
        .to be_valid
    end

    it "is valid when one of them is provided" do
      factory_context = create_node_factory_context({ "value" => "anything" })
      expect(described_class.new(factory_context)).to be_valid

      factory_context = create_node_factory_context({ "externalValue" => "/" })
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when both of them are provided" do
      factory_context = create_node_factory_context({ "value" => "anything",
                                                      "externalValue" => "/" })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("value and externalValue are mutually exclusive fields")
    end
  end
end
