# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::MediaType do
  it_behaves_like "node object factory", Openapi3Parser::Node::MediaType do
    let(:input) do
      {
        "schema" => {
          "$ref" => "#/components/schemas/Pet"
        },
        "examples" => {
          "cat" => {
            "summary" => "An example of a cat",
            "value" => {
              "name" => "Fluffy",
              "petType" => "Cat",
              "color" => "White",
              "gender" => "male",
              "breed" => "Persian"
            }
          },
          "dog" => {
            "summary" => "An example of a dog with a cat's name",
            "value" => {
              "name" => "Puma",
              "petType" => "Dog",
              "color" => "Black",
              "gender" => "Female",
              "breed" => "Mixed"
            }
          }
        }
      }
    end

    let(:document_input) do
      {
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "discriminator" => { "propertyName" => "petType" },
              "properties" => {
                "name" => { "type" => "string" },
                "petType" => { "type" => "string" }
              },
              "required" => %w[name petType]
            }
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input: document_input)
    end
  end

  it_behaves_like "mutually exclusive example"

  describe "examples default value" do
    it "defaults to a value of nil" do
      factory_context = create_node_factory_context({})
      node = described_class.new(factory_context).node(
        node_factory_context_to_node_context(factory_context)
      )
      expect(node["examples"]).to be_nil
    end
  end

  describe "validating encoding" do
    it "is valid when the encoding keys exist in the schema" do
      factory_context = create_node_factory_context(
        {
          "schema" => {
            "type" => "object",
            "properties" => { "name" => { "type" => "string" } }
          },
          "encoding" => { "name" => { "contentType" => "text/plain" } }
        }
      )

      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when the encoding keys don't exist in the schema" do
      factory_context = create_node_factory_context(
        {
          "schema" => {
            "type" => "object",
            "properties" => { "name" => { "type" => "string" } }
          },
          "encoding" => {
            "key_1" => { "contentType" => "text/plain" },
            "key_2" => { "contentType" => "text/plain" }
          }
        }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/encoding")
        .with_message("Keys are not defined as schema properties: key_1, key_2")
    end

    it "copes if the schema is invalid" do
      factory_context = create_node_factory_context(
        { "schema" => { "properties" => [] }, "encoding" => {} }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/schema/properties")
    end
  end
end
