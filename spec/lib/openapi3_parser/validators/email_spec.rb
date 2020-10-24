# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Email do
  describe ".call" do
    subject { described_class.call(email) }

    context "when input is not an email address" do
      let(:email) { "not an email" }

      it { is_expected.to eq %("#{email}" is not a valid email address) }
    end

    context "when input is an email address" do
      let(:email) { "kevin@example.com" }

      it { is_expected.to be_nil }
    end
  end
end
