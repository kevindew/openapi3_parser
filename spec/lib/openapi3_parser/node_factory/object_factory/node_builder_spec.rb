# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::NodeBuilder do
  describe ".errors" do
    it "returns an error collection" do
      factory = Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context(nil)
      )

      expect(described_class.errors(factory))
        .to be_a(Openapi3Parser::Validation::ErrorCollection)
    end

    it "returns an empty collection when there aren't errors" do
      factory = Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context({ "email" => "valid-email@example.com" })
      )

      expect(described_class.errors(factory)).to be_empty
    end

    it "returns errors when the type is correct but the data is not" do
      factory = Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context({ "email" => "invalid email" })
      )

      expect(described_class.errors(factory)).not_to be_empty
    end

    it "returns errors when given an unexpected type" do
      factory = Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context(123)
      )

      expect(described_class.errors(factory)).not_to be_empty
    end

    context "when input is nil" do
      let(:factory) do
        Openapi3Parser::NodeFactory::Contact.new(
          create_node_factory_context(nil)
        )
      end

      it "returns an empty collection when the factory allows a default" do
        allow(factory).to receive(:can_use_default?).and_return(true)
        expect(described_class.errors(factory)).to be_empty
      end

      it "returns an error when the factory doesn't allow a default" do
        allow(factory).to receive(:can_use_default?).and_return(false)
        expect(described_class.errors(factory)).not_to be_empty
      end
    end
  end

  describe ".node_data" do
    it "returns the data for a node" do
      factory_context = create_node_factory_context({ "name" => "Tom" })
      factory = Openapi3Parser::NodeFactory::Contact.new(factory_context)
      node_context = node_factory_context_to_node_context(factory_context)

      expect(described_class.node_data(factory, node_context))
        .to match(hash_including({ "name" => "Tom" }))
    end

    it "raises an error when given invalid data" do
      factory_context = create_node_factory_context({ "email" => "invalid email" })
      factory = Openapi3Parser::NodeFactory::Contact.new(factory_context)
      node_context = node_factory_context_to_node_context(factory_context)

      expect { described_class.node_data(factory, node_context) }
        .to raise_error(Openapi3Parser::Error::InvalidData)
    end

    it "raises an error when given an unexpected type for the data" do
      factory_context = create_node_factory_context(123)
      factory = Openapi3Parser::NodeFactory::Contact.new(factory_context)
      node_context = node_factory_context_to_node_context(factory_context)

      expect { described_class.node_data(factory, node_context) }
        .to raise_error(Openapi3Parser::Error::InvalidType)
    end

    context "when input is nil" do
      let(:factory_context) { create_node_factory_context(nil) }
      let(:factory) { Openapi3Parser::NodeFactory::Contact.new(factory_context) }
      let(:node_context) do
        node_factory_context_to_node_context(factory_context)
      end

      it "returns nil when the factory allows a default" do
        allow(factory).to receive(:can_use_default?).and_return(true)
        expect(described_class.node_data(factory, node_context)).to be_nil
      end

      it "raises an error when the factory doesn't allow a default" do
        allow(factory).to receive(:can_use_default?).and_return(false)
        expect { described_class.node_data(factory, node_context) }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end
  end
end
