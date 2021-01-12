# frozen_string_literal: true

RSpec.shared_examples "node object factory" do |klass|
  let(:node_factory_context) { create_node_factory_context(input) }
  let(:node_context) do
    node_factory_context_to_node_context(node_factory_context)
  end

  describe "#node" do
    it "returns an instance of #{klass}" do
      expect(described_class.new(node_factory_context).node(node_context))
        .to be_a(klass)
    end
  end

  describe "#valid?" do
    it "is valid" do
      expect(described_class.new(node_factory_context).valid?).to be(true)
    end
  end

  describe "#errors" do
    it "has no errors" do
      expect(described_class.new(node_factory_context).errors).to be_empty
    end
  end
end
