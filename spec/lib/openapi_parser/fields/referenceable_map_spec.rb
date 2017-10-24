require "openapi_parser/fields/referenceable_map"
require "openapi_parser/error"

RSpec.describe OpenapiParser::Fields::ReferenceableMap do
  let(:document) { instance_double("OpenapiParser::Document") }
  let(:namespace) { [] }

  it "returns a hash" do
    result = described_class.call({}, document, namespace)
    expect(result).to be_a Hash
  end

  it "can be passed a proc to transform results" do
    result = described_class.call(
      { "key" => 1 },
      document,
      namespace,
      require_objects: false
    ) { |value, _, _| value * 2 }

    expect(result).to match a_hash_including("key" => 2)
  end

  context "when an invalid key is specified" do
    let(:input) { { "bad/key" => 1 } }

    it "raises an error" do
      expect do
        described_class.call(input, document, namespace)
      end.to raise_error(OpenapiParser::Error)
    end
  end

  context "when objects are required and a non object is passed in" do
    let(:input) { { "key" => "non-object" } }

    it "raises an error" do
      expect do
        described_class.call(input, document, namespace)
      end.to raise_error(OpenapiParser::Error)
    end
  end

  context "when objects are required and an object is passed in" do
    let(:input) { { "key" => { "object" => "like" } } }

    it "doesn't raise an error" do
      expect do
        described_class.call(input, document, namespace)
      end.not_to raise_error
    end
  end
end
