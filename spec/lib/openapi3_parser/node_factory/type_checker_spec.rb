# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::TypeChecker do
  describe ".validate_type" do
    it "returns true when a type is valid" do
      expect(described_class.validate_type(create_validatable({}), type: Hash))
        .to be true
    end

    it "returns false and adds an error to the validatable when type is invalid" do
      validatable = create_validatable("blah")
      expect(described_class.validate_type(validatable, type: Hash))
        .to be false
      expect(validatable.errors.map(&:to_s))
        .to include "Invalid type. Expected Object"
    end
  end

  describe ".raise_on_invalid_type" do
    it "returns true when a type is valid" do
      factory_context = create_node_factory_context({})
      expect(described_class.raise_on_invalid_type(factory_context, type: Hash))
        .to be true
    end

    it "raises an error for an invalid type" do
      factory_context = create_node_factory_context("blah")
      expect { described_class.raise_on_invalid_type(factory_context, type: Hash) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid type for #/: Expected Object")
    end
  end

  describe ".validate_keys" do
    it "returns true when a type is valid" do
      validatable = create_validatable({ 1 => "a" })
      expect(described_class.validate_keys(validatable, type: Integer))
        .to be true
    end

    it "returns false and adds an error to the validatable when type is invalid" do
      validatable = create_validatable({ 1 => "a" })
      expect(described_class.validate_keys(validatable, type: String))
        .to be false

      expect(validatable.errors.map(&:to_s))
        .to include "Invalid keys. Expected keys to be of type String"
    end
  end

  describe ".raise_on_invalid_keys" do
    it "returns true when a type is valid" do
      factory_context = create_node_factory_context({ 1 => "a" })
      expect(described_class.raise_on_invalid_keys(factory_context, type: Integer))
        .to be true
    end

    it "raises an error for an invalid type" do
      factory_context = create_node_factory_context({ 1 => "a" })
      expect { described_class.raise_on_invalid_keys(factory_context, type: String) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid keys for #/: Expected keys to be of type String")
    end
  end

  it "can validate booleans with a boolean symbol" do
    expect(described_class.validate_type(create_validatable(true), type: :boolean))
      .to be true

    expect(described_class.validate_type(create_validatable(false), type: :boolean))
      .to be true

    expect(described_class.validate_type(create_validatable("string"), type: :boolean))
      .to be false
  end

  it "raises an error when type is not an expected type" do
    expect { described_class.validate_type(create_validatable, type: "string") }
      .to raise_error(Openapi3Parser::Error::UnvalidatableType,
                      "Expected string to be a Class not a String")
  end

  def create_validatable(input = "")
    factory_context = create_node_factory_context(input)
    factory = instance_double(Openapi3Parser::NodeFactory::Field,
                              context: factory_context)
    Openapi3Parser::Validation::Validatable.new(factory)
  end
end
