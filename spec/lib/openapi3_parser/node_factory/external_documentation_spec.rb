# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ExternalDocumentation do
  it_behaves_like "node object factory",
                  Openapi3Parser::Node::ExternalDocumentation do
    let(:input) do
      {
        "description" => "Test",
        "url" => "http://www.yahoo.com"
      }
    end
  end

  describe "validating URL" do
    it "is valid for an actual URL" do
      factory_context = create_node_factory_context(
        { "url" => "https://example.com/path" }
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an incorrect URL" do
      factory_context = create_node_factory_context(
        { "url" => "not a url" }
      )
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/url")
    end
  end
end
