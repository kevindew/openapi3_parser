# frozen_string_literal: true

RSpec.shared_examples "a extendable node" do
  context "when there are extensions" do
    let(:extensions) do
      {
        "x-anExtension" => "test",
        "x-anotherOne" => %w[one two three]
      }
    end

    it "can initialise with extensions" do
      expect { described_class.new(input, context) }.to_not raise_error
    end

    it "can access extensions by their name" do
      instance = described_class.new(input, context)
      expect(instance.extension("anExtension")).to eq "test"
      expect(instance.extension("anotherOne")).to eq %w[one two three]
    end
  end
end
