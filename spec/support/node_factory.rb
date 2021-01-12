# frozen_string_literal: true

RSpec.shared_examples "node factory" do |data_type|
  it "responds to #node" do
    instance = described_class.new(node_factory_context)
    expect(instance).to respond_to(:node)
  end

  it "responds to #default" do
    instance = described_class.new(node_factory_context)
    expect(instance).to respond_to(:default)
  end

  it "defaults to being valid" do
    expect(described_class.new(node_factory_context)).to be_valid
  end

  it "defaults to having an empty error collection" do
    errors = described_class.new(node_factory_context).errors

    expect(errors).to be_a(Openapi3Parser::Validation::ErrorCollection)
    expect(errors).to be_empty
  end

  it "has #data in the expected type" do
    expect(described_class.new(node_factory_context).data)
      .to be_a(data_type)
  end

  it "has #resolved_input in the expected type" do
    expect(described_class.new(node_factory_context).resolved_input)
      .to be_a(data_type)
  end

  it "has #raw_input in the expected type" do
    expect(described_class.new(node_factory_context).raw_input)
      .to be_a(data_type)
  end
end
