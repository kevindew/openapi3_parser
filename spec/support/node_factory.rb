# frozen_string_literal: true

RSpec.shared_examples "node factory" do |data_type|
  describe "#node" do
    subject { described_class.new(node_factory_context) }

    it { is_expected.to respond_to(:node) }
  end

  describe "#valid?" do
    subject { described_class.new(node_factory_context).valid? }

    it { is_expected.to be true }
  end

  describe "#errors" do
    subject { described_class.new(node_factory_context).errors }

    it { is_expected.to be_empty }
    it { is_expected.to be_a(Openapi3Parser::Validation::ErrorCollection) }
  end

  describe "#data" do
    subject { described_class.new(node_factory_context).data }

    it { is_expected.to be_a(data_type) }
  end

  describe "#resolved_input" do
    subject { described_class.new(node_factory_context).resolved_input }

    it { is_expected.to be_a(data_type) }
  end

  describe "#raw_input" do
    subject { described_class.new(node_factory_context).raw_input }

    it { is_expected.to be_a(data_type) }
  end

  describe "#default" do
    subject { described_class.new(node_factory_context) }

    it { is_expected.to respond_to(:default) }
  end
end
