# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Field do
  it_behaves_like "node factory", ::Integer do
    let(:node_factory_context) { create_node_factory_context(1) }
  end

  describe "#node" do
    it "returns the input" do
      expect(create_node(1)).to be(1)
    end

    it "raises an error when an input type is specified and doesn't match" do
      expect { create_node("string", input_type: Integer) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid type for #/: Expected Integer")
    end

    it "doesn't raise an error when an input type is specified and the input is nil" do
      expect { create_node(nil, input_type: Integer) }.not_to raise_error
    end

    it "raises an error when input fails a passed validation constraint" do
      validation_rule = ->(validatable) { validatable.add_error("Fail") }
      expect { create_node(1, validate: validation_rule) }
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
