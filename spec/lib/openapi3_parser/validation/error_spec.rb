# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validation::Error do
  describe ".for_type" do
    let(:node_factory_context) { create_node_factory_context({}) }

    it "returns nil when there isn't a factory class" do
      instance = described_class.new("", node_factory_context)
      expect(instance.for_type).to be_nil
    end

    it "returns the last class for a nested class" do
      instance = described_class.new("",
                                     node_factory_context,
                                     Openapi3Parser::NodeFactory::Contact)
      expect(instance.for_type).to eq "Contact"
    end

    it "returns '(anonymous)' when there isn't a factory name" do
      factory_class = Class.new
      instance = described_class.new("", node_factory_context, factory_class)
      expect(instance.for_type).to eq "(anonymous)"
    end
  end
end
