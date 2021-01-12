# frozen_string_literal: true

RSpec.shared_examples "mutually exclusive example" do
  let(:input) { {} }

  it "is valid when neither example or examples are provided" do
    instance = described_class.new(create_node_factory_context(input))
    expect(instance).to be_valid
  end

  it "is valid when one of them is provided" do
    factory_context = create_node_factory_context(
      input.merge({ "example" => "anything" })
    )
    expect(described_class.new(factory_context)).to be_valid

    factory_context = create_node_factory_context(
      input.merge({ "examples" => {} })
    )
    expect(described_class.new(factory_context)).to be_valid
  end

  it "is invalid when both of them are provided" do
    factory_context = create_node_factory_context({ "example" => "anything",
                                                    "examples" => {} })
    instance = described_class.new(factory_context)
    expect(instance).not_to be_valid
    expect(instance)
      .to have_validation_error("#/")
      .with_message("example and examples are mutually exclusive fields")
  end
end
