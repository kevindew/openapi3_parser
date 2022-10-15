# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Schema::V3_0 do
  it_behaves_like "node object factory", Openapi3Parser::Node::Schema::V3_0 do
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
      create_node_factory_context(input, document_input: document_input)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field", field: "nullable", defaults_to: false do
    let(:node_factory_context) do
      create_node_factory_context({ "nullable" => nullable })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "readOnly",
                  defaults_to: false,
                  var_name: :read_only do
    let(:node_factory_context) do
      create_node_factory_context({ "readOnly" => read_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "writeOnly",
                  defaults_to: false,
                  var_name: :write_only do
    let(:node_factory_context) do
      create_node_factory_context({ "writeOnly" => write_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "deprecated",
                  defaults_to: false,
                  var_name: :deprecated do
    let(:node_factory_context) do
      create_node_factory_context({ "deprecated" => deprecated })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "validating items" do
    it "is valid when type is 'array' and items are provided" do
      instance = described_class.new(
        create_node_factory_context({ "type" => "array", "items" => { "type" => "string" } })
      )
      expect(instance).to be_valid
    end

    it "is valid when type isn't 'array' and items aren't provided" do
      instance = described_class.new(
        create_node_factory_context({ "type" => "string" })
      )
      expect(instance).to be_valid
    end

    it "is invalid when type is 'array' and items aren't provided" do
      instance = described_class.new(
        create_node_factory_context({ "type" => "array" })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("items must be defined for a type of array")
    end
  end

  describe "validating writeOnly and readOnly" do
    it "is invalid when both writeOnly and readOnly are true" do
      instance = described_class.new(
        create_node_factory_context({ "writeOnly" => true, "readOnly" => true })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("readOnly and writeOnly cannot both be true")
    end

    it "is valid when one of writeOnly and readOnly are true" do
      write_only = described_class.new(
        create_node_factory_context({ "writeOnly" => true })
      )
      expect(write_only).to be_valid

      read_only = described_class.new(
        create_node_factory_context({ "readOnly" => true })
      )
      expect(read_only).to be_valid
    end
  end

  describe "validating additionalProperties" do
    it "is valid for a boolean" do
      true_instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => true })
      )
      expect(true_instance).to be_valid

      false_instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => false })
      )
      expect(false_instance).to be_valid
    end

    it "is valid for a schema" do
      instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => { "type" => "object" } })
      )
      expect(instance).to be_valid
    end

    it "is invalid for something different" do
      instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => %w[item1 item2] })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/additionalProperties")
        .with_message("Expected a Boolean or an Object")
    end
  end
end
