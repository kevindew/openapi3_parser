# frozen_string_literal: true

require "openapi_parser/fields/map"
require "openapi_parser/error"

RSpec.describe OpenapiParser::Fields::Map do
  let(:context) do
    instance_double(
      "OpenapiParser::Context",
      stringify_namespace: "",
      next_namespace: next_context
    )
  end

  let(:next_context) { instance_double("OpenapiParser::Context") }

  describe ".call" do
    it "returns a hash" do
      result = described_class.call({}, context)
      expect(result).to be_a Hash
    end

    it "can be passed a block to transform results" do
      result = described_class.call(
        { "key" => 1 },
        context,
        value_type: nil
      ) { |value| value * 2 }

      expect(result).to match a_hash_including("key" => 2)
    end

    context "when value_type is Hash and a string is passed in" do
      let(:input) { { "key" => "non-object" } }

      it "raises an error" do
        expect do
          described_class.call(input, context, value_type: Hash)
        end.to raise_error(OpenapiParser::Error)
      end
    end

    context "when value_type is Hash and a hash is not passed in" do
      let(:input) { { "key" => { "object" => "like" } } }

      it "doesn't raise an error" do
        expect do
          described_class.call(input, context, value_type: Hash)
        end.not_to raise_error
      end
    end
  end

  describe ".reference_input" do
    let(:reference) { 2 }

    before do
      allow(next_context).to receive(:possible_reference).and_yield(reference)
    end

    it "returns a hash" do
      result = described_class.reference_input({}, context) { |x| x * 2 }
      expect(result).to be_a Hash
    end

    it "can return a reference" do
      result = described_class.reference_input(
        { "key" => 1 },
        context,
        value_type: nil
      ) { |x| x * 2 }

      expect(result).to match a_hash_including("key" => 4)
    end
  end
end
