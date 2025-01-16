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
end
