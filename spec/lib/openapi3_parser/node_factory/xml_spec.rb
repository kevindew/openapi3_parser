# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Xml do
  it_behaves_like "node object factory", Openapi3Parser::Node::Xml do
    let(:input) do
      {
        "namespace" => "http://example.com/schema/sample",
        "prefix" => "sample"
      }
    end
  end

  describe "validating namespace" do
    it "is valid when the namespace is a uri" do
      factory_context = create_node_factory_context(
        { "namespace" => "https://example.com/path", "prefix" => "sample" }
      )

      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when the namespace is not a uri" do
      factory_context = create_node_factory_context(
        { "namespace" => "not a url", "prefix" => "sample" }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/namespace")
        .with_message(%("not a url" is not a valid URI))
    end
  end
end
