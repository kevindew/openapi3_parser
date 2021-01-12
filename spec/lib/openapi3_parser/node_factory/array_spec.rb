# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Array do
  it_behaves_like "node factory", ::Array do
    let(:node_factory_context) { create_node_factory_context([]) }
  end

  describe "validating input" do
    it "is not valid when given a non-array input" do
      instance = described_class.new(create_node_factory_context("a string"))
      expect(instance).not_to be_valid
    end
  end

  describe "#node" do
    it "returns a type of Openapi3Parser::Node::Array" do
      expect(create_node([])).to be_a(Openapi3Parser::Node::Array)
    end

    context "when input is nil" do
      it "returns a Openapi3Parser::Node::Array when an array is specified as the default" do
        expect(create_node(nil, default: [])).to be_a(Openapi3Parser::Node::Array)
      end

      it "returns nil when nil is specified as the default" do
        expect(create_node(nil, default: nil)).to be_nil
      end
    end

    it "can return the default when given an empty array as input" do
      node = create_node([], default: [1], use_default_on_empty: true)
      expect(node.first).to be(1)
    end

    it "can build the items based on a value factory" do
      node = create_node([{ "name" => "Kenneth" }],
                         value_factory: Openapi3Parser::NodeFactory::Contact)

      expect(node.first).to be_a(Openapi3Parser::Node::Contact)
    end

    it "raises an error when the array values are the wrong type" do
      expect { create_node([1], value_input_type: Hash) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid type for #/0: Expected Object")
    end

    it "raises an error when input fails a passed validation constraint" do
      validation_rule = ->(validatable) { validatable.add_error("Fail") }
      expect { create_node([], validate: validation_rule) }
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
