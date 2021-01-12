# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ServerVariable do
  it_behaves_like "node object factory", Openapi3Parser::Node::ServerVariable do
    let(:input) do
      {
        "enum" => %w[8443 443],
        "default" => "8443"
      }
    end
  end

  describe "validating enum" do
    it "is valid when enum is not empty" do
      instance = described_class.new(
        create_node_factory_context({ "enum" => %w[test], "default" => "test" })
      )
      expect(instance).to be_valid
    end

    it "is valid when enum is empty" do
      instance = described_class.new(
        create_node_factory_context({ "enum" => [], "default" => "test" })
      )
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/enum")
    end
  end
end
