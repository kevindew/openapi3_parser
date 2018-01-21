# frozen_string_literal: true

RSpec.shared_examples "node object factory" do |klass|
  describe "#node" do
    subject { described_class.new(context).node }
    it { is_expected.to be_a(klass) }
  end

  describe "#valid?" do
    subject { described_class.new(context).valid? }
    it { is_expected.to be true }
  end

  describe "#errors" do
    subject { described_class.new(context).errors }
    it { is_expected.to be_empty }
  end
end
