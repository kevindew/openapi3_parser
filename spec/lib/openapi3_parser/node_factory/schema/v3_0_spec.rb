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
      create_node_factory_context(input, document_input:)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "schema factory"
end
