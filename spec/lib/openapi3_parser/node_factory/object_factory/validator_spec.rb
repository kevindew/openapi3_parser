# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::Validator do
  describe ".call" do
    let(:factory_class) do
      Class.new(Openapi3Parser::NodeFactory::Object) do
        field "name",
              required: true,
              validate: ->(v) { v.add_error("invalid") if v.input == "invalid name" }
        field "left"
        field "right"
        mutually_exclusive "left", "right"
        validate ->(v) { v.add_error("factory fail") if v.input["name"] == "invalid factory" }
      end
    end

    it "returns an error collection" do
      factory = factory_class.new(create_node_factory_context({}))

      expect(described_class.call(factory))
        .to be_a(Openapi3Parser::Validation::ErrorCollection)
    end

    context "when we aren't raising on invalid" do
      it "has no errors when input is valid" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid" })
        )

        expect(described_class.call(factory, raise_on_invalid: false))
          .to be_empty
      end

      it "has errors when a required field is missing" do
        factory = factory_class.new(create_node_factory_context({}))

        expect(described_class.call(factory, raise_on_invalid: false))
          .not_to be_empty
      end

      it "has errors when an unexpected field is provided" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid",
                                        "unexpected" => "field" })
        )

        expect(described_class.call(factory, raise_on_invalid: false))
          .not_to be_empty
      end

      it "has errors when there are mutually exclusive fields" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid",
                                        "left" => "a",
                                        "right" => "b" })
        )

        expect(described_class.call(factory, raise_on_invalid: false))
          .not_to be_empty
      end

      it "has errors when there are invalid fields" do
        factory_context = create_node_factory_context({ "name" => "invalid name" })
        factory = factory_class.new(factory_context)
        field_context = Openapi3Parser::NodeFactory::Context.next_field(
          factory_context,
          "name"
        )
        error = Openapi3Parser::Validation::Error.new("invalid",
                                                      field_context,
                                                      factory_class)

        expect(described_class.call(factory, raise_on_invalid: false))
          .to include(error)
      end

      it "has errors when there are failing factory validations" do
        factory_context = create_node_factory_context({ "name" => "invalid factory" })
        factory = factory_class.new(factory_context)
        error = Openapi3Parser::Validation::Error.new("factory fail",
                                                      factory_context,
                                                      factory_class)

        expect(described_class.call(factory, raise_on_invalid: false))
          .to include(error)
      end
    end

    context "when we are building a node" do
      it "doesn't raise an error when the input is valid" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid" })
        )

        expect { described_class.call(factory, raise_on_invalid: true) }
          .not_to raise_error
      end

      it "raises an error when a required field is missing" do
        factory = factory_class.new(create_node_factory_context({}))

        expect { described_class.call(factory, raise_on_invalid: true) }
          .to raise_error(Openapi3Parser::Error::MissingFields)
      end

      it "raises an error when an unexpected field is provided" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid",
                                        "unexpected" => "field" })
        )

        expect { described_class.call(factory, raise_on_invalid: true) }
          .to raise_error(Openapi3Parser::Error::UnexpectedFields)
      end

      it "raises an error when there are mutually exclusive fields" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "valid",
                                        "left" => "a",
                                        "right" => "b" })
        )

        expect { described_class.call(factory, raise_on_invalid: true) }
          .to raise_error(Openapi3Parser::Error::UnexpectedFields)
      end

      it "raises an error when there are invalid fields" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "invalid name" })
        )

        expect { described_class.call(factory, raise_on_invalid: true) }
          .to raise_error(Openapi3Parser::Error::InvalidData,
                          "Invalid data for #/name: invalid")
      end

      it "raises an error there are failing factory validations" do
        factory = factory_class.new(
          create_node_factory_context({ "name" => "invalid factory" })
        )

        expect { described_class.call(factory, raise_on_invalid: true) }
          .to raise_error(Openapi3Parser::Error::InvalidData,
                          "Invalid data for #/: factory fail")
      end
    end
  end
end
