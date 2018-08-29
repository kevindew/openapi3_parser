# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::ComponentKeys do
  describe ".call" do
    subject { described_class.call(key => {}) }

    context "when input is an invalid component key" do
      let(:key) { "Invalid Key" }
      it { is_expected.to eq "Contains invalid keys: Invalid Key" }
    end

    context "when input is a valid component key" do
      let(:key) { "valid.key" }
      it { is_expected.to be_nil }
    end
  end
end
