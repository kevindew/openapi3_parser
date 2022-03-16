# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Object do
  let(:node_factory_context) { create_node_factory_context({}) }
  let(:instance) { described_class.new(node_factory_context) }

  it_behaves_like "node factory", ::Hash

  describe "#allowed_fields" do
    it "returns the keys of fields that are allowed" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        field "a", allowed: true
        field "b", allowed: false
        field "c", allowed: true
      end

      instance = factory_class.new(create_node_factory_context({}))

      expect(instance.allowed_fields).to match_array(%w[a c])
    end
  end

  describe "#required_fields" do
    it "returns the keys of fields that are required" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        field "a", required: true
        field "b", required: false
        field "c", required: true
      end

      instance = factory_class.new(create_node_factory_context({}))

      expect(instance.required_fields).to match_array(%w[a c])
    end

    it "only returns allowed fields" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        field "a", required: true, allowed: true
        field "b", required: true, allowed: false
      end

      instance = factory_class.new(create_node_factory_context({}))

      expect(instance.required_fields).to match_array(%w[a])
    end
  end
end
