# frozen_string_literal: true

RSpec.shared_examples "mutually exclusive example" do
  subject { described_class.new(node_factory_context) }

  context "when neither example or examples is provided" do
    let(:example) { nil }
    let(:examples) { nil }

    it { is_expected.to be_valid }
  end

  context "when an example is provided" do
    let(:example) { "anything" }
    let(:examples) { nil }

    it { is_expected.to be_valid }
  end

  context "when examples are provided" do
    let(:example) { nil }
    let(:examples) { {} }

    it { is_expected.to be_valid }
  end

  context "when both are provided" do
    let(:example) { "anything" }
    let(:examples) { {} }

    it do
      expect(subject)
        .to have_validation_error("#/")
        .with_message("example and examples are mutually exclusive fields")
    end
  end
end
