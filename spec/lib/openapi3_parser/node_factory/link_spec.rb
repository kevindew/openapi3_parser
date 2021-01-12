# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Link do
  it_behaves_like "node object factory", Openapi3Parser::Node::Link do
    let(:input) do
      {
        "operationRef" => "#/paths/~12.0~1repositories~1{username}/get",
        "parameters" => { "username" => "$response.body#/username" }
      }
    end
  end

  describe "validating operationRef and operationId are mutually exclusive" do
    it "is invalid when neither are provided" do
      instance = described_class.new(create_node_factory_context({}))
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("One of operationRef and operationId is required")
    end

    it "is valid when one of them is provided" do
      factory_context = create_node_factory_context({ "operationRef" => "#/test" })
      expect(described_class.new(factory_context)).to be_valid

      factory_context = create_node_factory_context({ "operationId" => "getOperation" })
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when both of them are provided" do
      factory_context = create_node_factory_context({ "operationRef" => "#/test",
                                                      "operationId" => "getOperation" })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("operationRef and operationId are mutually exclusive fields")
    end
  end
end
