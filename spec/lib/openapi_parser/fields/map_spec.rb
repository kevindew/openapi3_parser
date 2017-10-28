require "openapi_parser/fields/map"
require "openapi_parser/error"

RSpec.describe OpenapiParser::Fields::Map do
  let(:context) do
    instance_double(
      "OpenapiParser::Context",
      stringify_namespace: "",
      next_namespace: instance_double("OpenapiParser::Context")
    )
  end

  it "returns a hash" do
    result = described_class.call({}, context)
    expect(result).to be_a Hash
  end

  it "can be passed a proc to transform results" do
    result = described_class.call(
      { "key" => 1 },
      context,
      require_objects: false
    ) { |value, _, _| value * 2 }

    expect(result).to match a_hash_including("key" => 2)
  end

  context "when objects are required and a non object is passed in" do
    let(:input) { { "key" => "non-object" } }

    it "raises an error" do
      expect do
        described_class.call(input, context)
      end.to raise_error(OpenapiParser::Error)
    end
  end

  context "when objects are required and an object is passed in" do
    let(:input) { { "key" => { "object" => "like" } } }

    it "doesn't raise an error" do
      expect do
        described_class.call(input, context)
      end.not_to raise_error
    end
  end
end
