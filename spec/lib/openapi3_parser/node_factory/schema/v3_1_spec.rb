# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Schema::V3_1 do
  # TODO: perhaps a behaves like referenceable node object factory?

  # Basic c+p of V3_0 Schema test for now
  it_behaves_like "node object factory", Openapi3Parser::Node::Schema::V3_1 do
    let(:input) do
      {
        "allOf" => [
          { "$ref" => "#/components/schemas/Pet" },
          {
            "type" => "object",
            "properties" => {
              "bark" => { "type" => "string" }
            }
          }
        ]
      }
    end

    let(:document_input) do
      {
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "required" => %w[pet_type],
              "properties" => {
                "pet_type" => { "type" => "string" }
              },
              "discriminator" => {
                "propertyName" => "pet_type",
                "mapping" => { "cachorro" => "Dog" }
              }
            }
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input:)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "schema factory"

  describe "boolean input" do
    it "is valid for a boolean input" do
      instance = described_class.new(create_node_factory_context(false))

      expect(instance).to be_valid
      expect(instance.boolean_input?).to be(true)
    end

    it "can build a Schema::V3_1 node with a boolean input" do
      node_factory_context = create_node_factory_context(true)
      instance = described_class.new(node_factory_context)
      node_context = node_factory_context_to_node_context(node_factory_context)
      node = instance.node(node_context)

      expect(node).to be_an_instance_of(Openapi3Parser::Node::Schema::V3_1)
    end

    it "sets the data attribute to a boolean when that is input" do
      node_factory_context = create_node_factory_context(true)
      instance = described_class.new(node_factory_context)

      expect(instance.data).to be(true)
    end

    it "sets the data attribute to nil when given a type other than boolean or object" do
      node_factory_context = create_node_factory_context(25)
      instance = described_class.new(node_factory_context)

      expect(instance.data).to be_nil
    end

    context "when a referenced schema is a boolean" do
      let(:document_input) do
        {
          "components" => {
            "schemas" => {
              "Bool" => true
            }
          }
        }
      end

      it "is valid" do
        input = { "$ref" => "#/components/schemas/Bool" }
        instance = described_class.new(create_node_factory_context(input, document_input:))

        expect(instance).to be_valid
        expect(instance.boolean_input?).to be(true)
      end

      it "doesn't merge any fields" do
        input = {
          "description" => "A description that will be ignored",
          "$ref" => "#/components/schemas/Bool"
        }

        instance = described_class.new(create_node_factory_context(input, document_input:))

        expect(instance.resolved_input).to be(true)
      end
    end
  end

  describe "type field" do
    it "is valid for a string input of the 7 allowed types" do
      described_class::JSON_SCHEMA_ALLOWED_TYPES.each do |type|
        instance = described_class.new(
          create_node_factory_context({ "type" => type })
        )

        expect(instance).to be_valid
      end
    end

    it "is valid for an array of unique string items" do
      instance = described_class.new(
        create_node_factory_context({
                                      "type" => described_class::JSON_SCHEMA_ALLOWED_TYPES
                                    })
      )

      expect(instance).to be_valid
    end

    it "defaults to a value of nil" do
      instance = described_class.new(create_node_factory_context({}))

      expect(instance.data["type"]).to be_nil
      expect(instance).to be_valid
    end

    it "is invalid for an input type other than string or array" do
      instance = described_class.new(
        create_node_factory_context({ "type" => { "object" => "hi" } })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("type must be a string or an array")
    end

    it "is invalid for a string outside the 7 allowed types" do
      instance = described_class.new(
        create_node_factory_context({ "type" => "oogabooga" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("type (oogabooga) must be one of null, boolean, object, array, number, string and integer")
    end

    it "is invalid for an array with inputs other than strings" do
      instance = described_class.new(
        create_node_factory_context({ "type" => [12, 0.5] })
      )

      message = "type contains unexpected items (12 and 0.5) outside of " \
                "null, boolean, object, array, number, string and integer"
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message(message)
    end

    it "is invalid for an array with repeated items" do
      allowed_type = described_class::JSON_SCHEMA_ALLOWED_TYPES.first
      factory_context = create_node_factory_context({ "type" => [allowed_type, allowed_type] })

      instance = described_class.new(factory_context)

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("Duplicate entries in type array")
    end
  end

  describe "examples field" do
    it "is valid with an array with any type values" do
      instance = described_class.new(
        create_node_factory_context({ "examples" => [%w[a b], "test", nil] })
      )

      expect(instance).to be_valid
    end

    it "is invalid for a type other than array" do
      instance = described_class.new(
        create_node_factory_context({ "examples" => "string" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/examples")
        .with_message("Invalid type. Expected Array")
    end
  end

  describe "contentMediaType field" do
    it "is valid with a media type string" do
      instance = described_class.new(
        create_node_factory_context({ "contentMediaType" => "image/png" })
      )

      expect(instance).to be_valid
    end

    it "is invalid with a non media type string" do
      instance = described_class.new(
        create_node_factory_context({ "contentMediaType" => "not a media type" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/contentMediaType")
        .with_message('"not a media type" is not a valid media type')
    end
  end

  describe "prefixItems field" do
    it "is valid with an array with schema values" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => [{ "type" => "string" }] })
      )

      expect(instance).to be_valid
    end

    it "is invalid for a type other than array" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => "string" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/prefixItems")
        .with_message("Invalid type. Expected Array")
    end

    it "is invalid for values other than objects" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => %w[string] })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/prefixItems/0")
        .with_message("Invalid type. Expected Object")
    end
  end
end
