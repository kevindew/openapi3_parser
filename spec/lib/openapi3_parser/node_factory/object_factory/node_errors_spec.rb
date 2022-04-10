# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::NodeErrors do
  describe ".call" do
    it "returns a validation collection" do
      factory_class = Openapi3Parser::NodeFactory::Object

      factory_context = create_node_factory_context(1)
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).to be_an_instance_of(Openapi3Parser::Validation::ErrorCollection)
    end

    it "has validation errors for input other than an object" do
      factory_class = Openapi3Parser::NodeFactory::Object
      factory_context = create_node_factory_context("not an object")
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).not_to be_empty
    end

    it "has no validation errors for nil input with an allowed default" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        def can_use_default?
          true
        end
      end

      factory_context = create_node_factory_context(nil)
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).to be_empty
    end

    it "has no validation errors for an object without issues" do
      factory_class = Openapi3Parser::NodeFactory::Object
      factory_context = create_node_factory_context({})
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).to be_empty
    end

    it "has validation errors for nil input and can't use default" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        def can_use_default?
          false
        end
      end

      factory_context = create_node_factory_context(nil)
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).not_to be_empty
    end

    it "has validation errors for factory validation issues" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        validate do |validatable|
          validatable.add_error("Error")
        end
      end

      factory_context = create_node_factory_context({})
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors).not_to be_empty
    end

    it "doesn't validate the object if there is a type error" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        validate do |validatable|
          validatable.add_error("Error")
        end
      end

      factory_context = create_node_factory_context("not an object")
      errors = described_class.call(factory_class.new(factory_context))

      expect(errors.count).to be(1)
      expect(errors.first.message).to match(/invalid type/i)
    end
  end
end
