# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Reference do
  # TODO: perhaps a behaves like referenceable node object factory?

  def create_instance(input)
    factory_context = create_node_factory_context(
      input,
      document_input: { contact: {} }
    )
    factory = Openapi3Parser::NodeFactory::Contact
    described_class.new(factory_context, factory)
  end

  def create_node(input)
    instance = create_instance(input)
    node_context = node_factory_context_to_node_context(instance.context)
    instance.node(node_context)
  end

  describe "#node" do
    it "can return the referenced node" do
      expect(create_node({ "$ref" => "#/contact" }))
        .to be_a(Openapi3Parser::Node::Contact)
    end

    it "raises an error when the reference input is the wrong type" do
      expect { create_node("a string") }
        .to raise_error(Openapi3Parser::Error::InvalidType)
    end

    it "raises an error when the reference input is missing fields" do
      expect { create_node({}) }
        .to raise_error(Openapi3Parser::Error::MissingFields)
    end

    it "raises an error when the reference is invalid" do
      expect { create_node({ "$ref" => "invalid reference" }) }
        .to raise_error(Openapi3Parser::Error::InvalidData)
    end

    it "raises an error when the reference is unresolvable" do
      expect { create_node({ "$ref" => "#/cant-find-this" }) }
        .to raise_error(Openapi3Parser::Error::InvalidData)
    end
  end

  describe "#valid?" do
    it "returns true for valid input" do
      expect(create_instance({ "$ref" => "#/contact" }).valid?)
        .to be true
    end

    it "returns false for invalid input" do
      expect(create_instance({}).valid?).to be false
    end
  end

  describe "#errors" do
    it "is empty when it is valid" do
      expect(create_instance({ "$ref" => "#/contact" }).errors)
        .to be_empty
    end

    it "has validation errors when it is invalid" do
      expect(create_instance({ "$ref" => "#/contact", "extra" => "field" }))
        .to have_validation_error("#/").with_message("Unexpected fields: extra")
    end

    it "has no validation errors when invalid and in a recursive loop" do
      # If the object is in a recursive loop we can never fully validate
      # the item so we abort early knowing that the recursive loop will
      # produce an error on the item calling this.

      # cheat a recursive loop by suggesting we've already visited this node
      factory_context = create_node_factory_context(
        { "$ref" => "#/contact", "extra" => "field" },
        reference_pointer_fragments: ["#/%24ref"]
      )
      instance = described_class.new(factory_context, Openapi3Parser::NodeFactory::Contact)

      expect(instance.errors).to be_empty
    end
  end

  describe "#resolves?" do
    let(:factory) do
      Openapi3Parser::NodeFactory::OptionalReference.new(
        Openapi3Parser::NodeFactory::Contact
      )
    end

    it "returns true when following a chain of references leads to an object" do
      factory_context = create_node_factory_context(
        { "$ref" => "#/contact2" },
        document_input: {
          contact1: { "$ref" => "#/contact2" },
          contact2: { "$ref" => "#/contact3" },
          contact3: {}
        },
        pointer_segments: %w[contact1]
      )
      instance = described_class.new(factory_context, factory)

      expect(instance.resolves?([instance.context.source_location])).to be true
    end

    it "returns false when following a chain of references leads to a recursive loop" do
      factory_context = create_node_factory_context(
        { "$ref" => "#/contact2" },
        document_input: {
          contact1: { "$ref" => "#/contact2" },
          contact2: { "$ref" => "#/contact3" },
          contact3: { "$ref" => "#/contact1" }
        },
        pointer_segments: %w[contact1]
      )
      instance = described_class.new(factory_context, factory)

      expect(instance.resolves?([instance.context.source_location])).to be false
    end
  end
end
