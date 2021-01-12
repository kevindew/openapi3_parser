# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Map do
  it_behaves_like "node factory", ::Hash do
    let(:node_factory_context) { create_node_factory_context({}) }
  end

  describe "validating input" do
    it "is not valid when given a non-hash input" do
      instance = described_class.new(create_node_factory_context("a string"))
      expect(instance).not_to be_valid
    end
  end

  describe "#node" do
    it "returns a type of Openapi3Parser::Node::Map" do
      expect(create_node({})).to be_a(Openapi3Parser::Node::Map)
    end

    context "when input is nil" do
      it "returns a Openapi3Parser::Node::Map when a hash is specified as the default" do
        expect(create_node(nil, default: {})).to be_a(Openapi3Parser::Node::Map)
      end

      it "returns nil when nil is specified as the default" do
        expect(create_node(nil, default: nil)).to be_nil
      end
    end

    it "can build the items based on a value factory" do
      node = create_node({ "item" => { "name" => "Kenneth" } },
                         value_factory: Openapi3Parser::NodeFactory::Contact)

      expect(node["item"]).to be_a(Openapi3Parser::Node::Contact)
    end

    it "allows extensions to be a different input type to valid_input_type" do
      input = { "real" => 1, "x-item" => "string" }
      expect { create_node(input, allow_extensions: true, value_input_type: Integer) }
        .not_to raise_error
    end

    it "raises an error when a type other than string is given as an input key" do
      expect { create_node({ 1 => "Test" }) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid keys for #/: Expected keys to be of type String")
    end

    it "raises an error when the hash values are the wrong type" do
      expect { create_node({ "a" => "Test" }, value_input_type: Integer) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid type for #/a: Expected Integer")
    end

    it "raises an error when input fails a passed validation constraint" do
      validation_rule = ->(validatable) { validatable.add_error("Fail") }
      expect { create_node({}, validate: validation_rule) }
        .to raise_error(Openapi3Parser::Error::InvalidData)
    end

    def create_node(input, **options)
      node_factory_context = create_node_factory_context(input)
      instance = described_class.new(node_factory_context, **options)
      node_context = node_factory_context_to_node_context(node_factory_context)
      instance.node(node_context)
    end
  end
end
