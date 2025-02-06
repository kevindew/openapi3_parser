# frozen_string_literal: true

RSpec.describe Openapi3Parser::OpenapiVersion do
  it "provides ability to compare against primitive types" do
    expect(described_class.new("3.12")).to be > "3.9"
    expect(described_class.new("3.1")).to be >= 3.1
    expect(described_class.new("3.0")).not_to be < "3"
  end
end
