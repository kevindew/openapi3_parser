# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::FieldConfig do
  def create_contact_validatable(node_factory_context = nil)
    Openapi3Parser::Validation::Validatable.new(
      Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context({ "name" => "Mike" })
      ),
      context: node_factory_context
    )
  end

  describe "#factory?" do
    it "returns true when the class is initialised with a factory" do
      instance = described_class.new(factory: Openapi3Parser::NodeFactory::Contact)
      expect(instance.factory?).to be(true)
    end

    it "returns false when the class is not initialised without a factory" do
      instance = described_class.new
      expect(instance.factory?).to be(false)
    end
  end

  describe "#initialize_factory" do
    it "returns a factory instance when initialised with a factory class" do
      instance = described_class.new(factory: Openapi3Parser::NodeFactory::Contact)
      context = create_node_factory_context({ "name" => "Mike" })
      expect(instance.initialize_factory(context))
        .to be_a(Openapi3Parser::NodeFactory::Contact)
    end

    it "can call a method on the parent factory when initialised with a symbol" do
      instance = described_class.new(factory: :give_me_a_factory)
      context = create_node_factory_context({})
      parent_factory = Class.new
      factory = instance_double(Openapi3Parser::NodeFactory::Contact)
      allow(parent_factory)
        .to receive(:give_me_a_factory)
        .with(context)
        .and_return(factory)

      expect(instance.initialize_factory(context, parent_factory))
        .to be(factory)
    end

    it "can be given a callable as a factory" do
      factory = instance_double(Openapi3Parser::NodeFactory::Contact)
      callable = ->(_context) { factory }
      instance = described_class.new(factory: callable)
      context = create_node_factory_context({})
      allow(callable).to receive(:call).with(context).and_return(factory)

      expect(instance.initialize_factory(context)).to be(factory)
    end
  end

  describe "#required?" do
    let(:context) { create_node_factory_context({ "name" => "Mike" }) }
    let(:factory) { Openapi3Parser::NodeFactory::Contact.new(context) }

    it "returns false when a required value isn't provided" do
      expect(described_class.new.required?(context, factory)).to be(false)
    end

    it "returns a value when one is provided" do
      instance = described_class.new(required: true)
      expect(instance.required?(context, factory)).to be(true)
    end

    it "converts non boolean values into booleans" do
      instance = described_class.new(required: nil)
      expect(instance.required?(context, factory)).to be(false)
    end

    it "calls the function when a callable is given" do
      allow(context).to receive(:required?).and_return(true)
      instance = described_class.new(required: ->(context) { context.required? })
      expect(instance.required?(context, factory)).to be(true)
    end

    it "calls the method on the factory when a symbol is given" do
      allow(factory).to receive(:my_factory_required).and_return(true)
      instance = described_class.new(required: :my_factory_required)
      expect(instance.required?(context, factory)).to be(true)
    end
  end

  describe "#check_input_type" do
    it "returns true when there isn't an expected type" do
      instance = described_class.new(input_type: nil)
      validatable = create_contact_validatable
      expect(instance.check_input_type(validatable)).to be(true)
    end

    it "returns true when the input is nil" do
      instance = described_class.new(input_type: String)
      validatable = create_contact_validatable(
        create_node_factory_context(nil)
      )

      expect(instance.check_input_type(validatable)).to be(true)
    end

    it "returns true when the input type matches" do
      instance = described_class.new(input_type: String)
      validatable = create_contact_validatable(
        create_node_factory_context("a string")
      )

      expect(instance.check_input_type(validatable)).to be(true)
    end

    context "when the type doesn't match" do
      let(:instance) { described_class.new(input_type: Integer) }
      let(:validatable) do
        create_contact_validatable(
          create_node_factory_context("not an integer")
        )
      end

      it "returns false" do
        expect(instance.check_input_type(validatable)).to be(false)
      end

      it "adds an error to the validatable" do
        expect { instance.check_input_type(validatable) }
          .to change { validatable.errors.count }.by(1)
      end

      it "raises an error when building_node is true" do
        expect { instance.check_input_type(validatable, building_node: true) }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end
  end

  describe "#validate_field" do
    it "returns true when there isnt a validation" do
      instance = described_class.new(validate: nil)
      validatable = create_contact_validatable
      expect(instance.validate_field(validatable)).to be(true)
    end

    it "returns true when the input is nil" do
      instance = described_class.new(validate: ->(_) {})
      validatable = create_contact_validatable(
        create_node_factory_context(nil)
      )

      expect(instance.validate_field(validatable)).to be(true)
    end

    it "returns true when the validation passes" do
      instance = described_class.new(validate: ->(_) {})
      validatable = create_contact_validatable

      expect(instance.validate_field(validatable)).to be(true)
    end

    it "can validate based off a symbol to call a partiular method on the factory" do
      instance = described_class.new(validate: :my_validation_method)
      validatable = create_contact_validatable
      allow(validatable.factory).to receive(:my_validation_method)

      instance.validate_field(validatable)
      expect(validatable.factory).to have_received(:my_validation_method)
    end

    context "when the validation fails" do
      let(:validatable) { create_contact_validatable }
      let(:instance) do
        described_class.new(validate: ->(v) { v.add_error("Error") })
      end

      it "returns false" do
        expect(instance.validate_field(validatable)).to be(false)
      end

      it "adds an error to the validatable" do
        expect { instance.validate_field(validatable) }
          .to change { validatable.errors.count }.by(1)
      end

      it "raises an error when building_node is true" do
        expect { instance.validate_field(validatable, building_node: true) }
          .to raise_error(Openapi3Parser::Error::InvalidData,
                          "Invalid data for #/: Error")
      end
    end
  end

  describe "#default" do
    let(:factory) do
      Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context({ "name" => "Mike" })
      )
    end

    it "returns nil when a default isn't provided" do
      expect(described_class.new.default(factory)).to be_nil
    end

    it "returns a value when one is provided" do
      instance = described_class.new(default: 123)
      expect(instance.default(factory)).to eq(123)
    end

    it "calls the function when a callable is given" do
      instance = described_class.new(default: -> { "a default" })
      expect(instance.default(factory)).to eq("a default")
    end

    it "calls the method on the factory when a symbol is given" do
      allow(factory).to receive(:my_factory_default).and_return("factory default")
      instance = described_class.new(default: :my_factory_default)
      expect(instance.default(factory)).to eq("factory default")
    end
  end
end
