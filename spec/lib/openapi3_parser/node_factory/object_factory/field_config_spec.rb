# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::FieldConfig do
  include Helpers::Context

  def create_contact_validatable(node_factory_context = nil)
    Openapi3Parser::Validation::Validatable.new(
      Openapi3Parser::NodeFactory::Contact.new(
        create_node_factory_context({ "name" => "Mike" })
      ),
      context: node_factory_context
    )
  end

  describe "#factory?" do
    subject { described_class.new(factory: factory).factory? }

    context "when initialised with a factory" do
      let(:factory) { :factory }
      it { is_expected.to be true }
    end

    context "when initialised without a factory" do
      let(:factory) { nil }
      it { is_expected.to be false }
    end
  end

  describe "#initialize_factory" do
    let(:node_factory_context) do
      create_node_factory_context({ "name" => "Mike" })
    end

    let(:parent_factory) { nil }

    subject do
      described_class
        .new(factory: factory)
        .initialize_factory(node_factory_context, parent_factory)
    end

    shared_examples "initialises Contact factory" do
      it { is_expected.to be_a(Openapi3Parser::NodeFactory::Contact) }
    end

    context "when initialised with a factory as a class" do
      let(:factory) { Openapi3Parser::NodeFactory::Contact }
      include_examples "initialises Contact factory"
    end

    context "when initialised with a factory as a method on parent factory" do
      let(:factory) { :contact_factory }
      let(:parent_factory) do
        class BasicFactory
          def contact_factory(node_factory_context)
            Openapi3Parser::NodeFactory::Contact.new(node_factory_context)
          end
        end
        BasicFactory.new
      end

      include_examples "initialises Contact factory"
    end

    context "when initialised with a callable factory" do
      let(:factory) do
        ->(context) { Openapi3Parser::NodeFactory::Contact.new(context) }
      end
      include_examples "initialises Contact factory"
    end
  end

  describe "#required?" do
    subject { described_class.new(required: required).required? }

    context "when initialised with required" do
      let(:required) { true }
      it { is_expected.to be true }
    end

    context "when initialised without required" do
      let(:required) { nil }
      it { is_expected.to be_falsy }
    end
  end

  describe "#check_input_type" do
    let(:validatable) { create_contact_validatable(node_factory_context) }
    let(:building_node) { false }

    subject(:check_input_type) do
      described_class.new(input_type: input_type)
                     .check_input_type(validatable, building_node)
    end

    context "when input type is valid" do
      let(:input_type) { String }
      let(:node_factory_context) { create_node_factory_context("a string") }

      it { is_expected.to be true }
    end

    context "when context input is nil" do
      let(:input_type) { String }
      let(:node_factory_context) { create_node_factory_context(nil) }

      it { is_expected.to be true }
    end

    context "when input type is invalid and building_node is false" do
      let(:input_type) { String }
      let(:node_factory_context) { create_node_factory_context(1) }
      let(:building_node) { false }

      it { is_expected.to be false }

      it "adds an error to validatable" do
        expect { check_input_type }
          .to change { validatable.errors.count }.by(1)
      end
    end

    context "when input type is invalid and building_node is true" do
      let(:input_type) { String }
      let(:node_factory_context) { create_node_factory_context(1) }
      let(:building_node) { true }

      it "raises an InvalidType error" do
        expect { check_input_type }
          .to raise_error(Openapi3Parser::Error::InvalidType)
      end
    end
  end

  describe "#validate_field" do
    let(:node_factory_context) { create_node_factory_context("a string") }
    let(:validatable) { create_contact_validatable(node_factory_context) }
    let(:building_node) { false }

    subject(:validate_field) do
      described_class.new(validate: validate)
                     .validate_field(validatable, building_node)
    end

    context "when not provided validation" do
      let(:validate) { nil }

      it { is_expected.to be true }
    end

    context "when context input is nil" do
      let(:validate) { ->(validatable) { validatable.add_error("bad") } }
      let(:node_factory_context) { create_node_factory_context(nil) }

      it { is_expected.to be true }
    end

    context "when there are no validation errors" do
      let(:validate) { ->(_validatable) { nil } }

      it { is_expected.to be true }
    end

    context "when there is a validation error and building_node is false" do
      let(:validate) { ->(validatable) { validatable.add_error("fail") }  }
      let(:building_node) { false }

      it { is_expected.to be false }

      it "adds an error to validatable" do
        expect { validate_field }
          .to change { validatable.errors.count }.by(1)
      end
    end

    context "when there is a validation error and building_node is true" do
      let(:validate) { ->(validatable) { validatable.add_error("fail") } }
      let(:building_node) { true }

      it "raises an InvalidData error" do
        expect { validate_field }
          .to raise_error(Openapi3Parser::Error::InvalidData,
                          "Invalid data for #/: fail")
      end
    end
  end

  describe "#default" do
    let(:factory) { double("factory") }
    subject(:run_default) do
      described_class.new(default: default).default(factory)
    end

    context "when nil is given as default" do
      let(:default) { nil }
      it { is_expected.to be_nil }
    end

    context "when a value is given as a default" do
      let(:default) { 123 }
      it { is_expected.to be 123 }
    end

    context "when a symbol of a factory method is given as default" do
      before do
        allow(factory).to receive(:factory_default).and_return("default")
      end
      let(:default) { :factory_default }

      it { is_expected.to be "default" }
    end

    context "when a callable is given as a default" do
      let(:default) { -> { true } }

      it { is_expected.to be true }
    end
  end
end
