# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::Reference do
  describe "#errors" do
    let(:input) { "#/test" }
    subject { described_class.new(input).errors }

    it { is_expected.to be_an_instance_of(Array) }

    context "when it's valid" do
      it { is_expected.to be_empty }
    end

    context "when it's not a string" do
      let(:input) { 12 }
      let(:errors) { ["Expected a string"] }
      it { is_expected.to match_array(errors) }
    end

    context "when it's an invalid URI" do
      let(:input) { "test test test" }
      let(:errors) { ["Could not parse as a URI"] }
      it { is_expected.to match_array(errors) }
    end

    context "when it's an invalid JSON pointer" do
      let(:input) { "./test#any-old-fragment" }
      let(:errors) { ["Invalid JSON pointer, expected a root slash"] }
      it { is_expected.to match_array(errors) }
    end
  end

  describe "#valid?" do
    let(:input) { "#/test" }
    subject { described_class.new(input).valid? }

    context "when it's valid" do
      it { is_expected.to be true }
    end

    context "when it's invalid" do
      let(:input) { "test test" }
      it { is_expected.to be false }
    end
  end
end
