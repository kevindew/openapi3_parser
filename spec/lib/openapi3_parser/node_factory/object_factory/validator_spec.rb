# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::Validator do
  include Helpers::Context

  describe ".call" do
    subject(:collection) { described_class.call(factory, building_node) }

    let(:factory_class) { Class.new(Openapi3Parser::NodeFactory::Object) }
    let(:node_factory_context) { create_node_factory_context(input) }
    let(:factory) { factory_class.new(node_factory_context) }
    let(:input) { {} }
    let(:building_node) { false }

    it { is_expected.to be_a(Openapi3Parser::Validation::ErrorCollection) }

    context "when there are no validation issues" do
      it { is_expected.to be_empty }
    end

    context "when there are missing required fields" do
      let(:factory_class) do
        Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name", required: true
        end
      end

      context "and we are building the node" do
        let(:building_node) { true }

        it "raises an error" do
          expect { collection }
            .to raise_error(Openapi3Parser::Error::MissingFields)
        end
      end

      context "and we are not building the node" do
        let(:building_node) { false }

        it { is_expected.not_to be_empty }
      end
    end

    context "when there are unexpected fields" do
      let(:input) { { "extra_field" => true } }

      context "and we are building the node" do
        let(:building_node) { true }

        it "raises an error" do
          expect { collection }
            .to raise_error(Openapi3Parser::Error::UnexpectedFields)
        end
      end

      context "and we are not building the node" do
        let(:building_node) { false }

        it { is_expected.not_to be_empty }
      end
    end

    context "when there are mututally exclusive fields" do
      let(:factory_class) do
        Class.new(Openapi3Parser::NodeFactory::Object) do
          field "left"
          field "right"
          mutually_exclusive "left", "right"
        end
      end
      let(:input) { { "left" => true, "right" => true } }

      context "and we are building the node" do
        let(:building_node) { true }

        it "raises an error" do
          expect { collection }
            .to raise_error(Openapi3Parser::Error::UnexpectedFields)
        end
      end

      context "and we are not building the node" do
        let(:building_node) { false }

        it { is_expected.not_to be_empty }
      end
    end

    context "when there are invalid fields" do
      let(:factory_class) do
        Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name",
                validate: ->(v) { v.add_error("invalid") }
        end
      end
      let(:input) { { "name" => true } }

      context "and we are building the node" do
        let(:building_node) { true }

        it "raises an error" do
          expect { collection }
            .to raise_error(Openapi3Parser::Error::InvalidData,
                            "Invalid data for #/name: invalid")
        end
      end

      context "and we are not building the node" do
        let(:building_node) { false }
        let(:error) do
          context = Openapi3Parser::NodeFactory::Context.next_field(
            node_factory_context,
            "name"
          )

          Openapi3Parser::Validation::Error.new("invalid",
                                                context,
                                                factory_class)
        end

        it { is_expected.to include(error) }
      end
    end

    context "when there are failing factory validations" do
      let(:factory_class) do
        Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name"
          validate ->(v) { v.add_error("fail") }
        end
      end
      let(:input) { { "name" => true } }

      context "and we are building the node" do
        let(:building_node) { true }

        it "raises an error" do
          expect { collection }
            .to raise_error(Openapi3Parser::Error::InvalidData,
                            "Invalid data for #/: fail")
        end
      end

      context "and we are not building the node" do
        let(:building_node) { false }
        let(:error) do
          Openapi3Parser::Validation::Error.new("fail",
                                                node_factory_context,
                                                factory_class)
        end

        it { is_expected.to include(error) }
      end
    end
  end
end
