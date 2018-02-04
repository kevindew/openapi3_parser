# frozen_string_literal: true

require "openapi3_parser/node_factories/schema"
require "openapi3_parser/node/schema"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Schema do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Schema do
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

    let(:context) { create_context(input, document_input: document_input) }
  end
end
