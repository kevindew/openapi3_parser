# frozen_string_literal: true

RSpec.shared_examples "node object factory" do |klass|
  describe "#node" do
    subject { described_class.new(node_factory_context).node(node_context) }

    it { is_expected.to be_a(klass) }
  end

  describe "#valid?" do
    subject { described_class.new(node_factory_context).valid? }

    it { is_expected.to be true }
  end

  describe "#errors" do
    subject { described_class.new(node_factory_context).errors }

    it { is_expected.to be_empty }
  end
end
