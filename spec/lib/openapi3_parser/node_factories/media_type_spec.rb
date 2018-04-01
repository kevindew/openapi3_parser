# frozen_string_literal: true

require "openapi3_parser/node_factories/media_type"
require "openapi3_parser/node/media_type"

require "support/helpers/context"
require "support/mutually_exclusive_example"
require "support/node_object_factory"

RSpec.describe Openapi3Parser::NodeFactories::MediaType do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::MediaType do
    let(:input) do
      {
        "schema" => {
          "$ref" => "#/components/schemas/Pet"
        },
        "examples" => {
          "cat"  => {
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
            "value"  =>  {
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

    let(:context) { create_context(input, document_input: document_input) }
  end

  describe "examples default value" do
    subject(:node) { described_class.new(context).node }
    let(:context) do
      create_context("examples" => nil)
    end

    it "defaults to a value of nil" do
      expect(node["examples"]).to be_nil
    end
  end

  it_behaves_like "mutually exclusive example" do
    let(:context) do
      create_context(
        "example" => example,
        "examples" => examples
      )
    end
  end
end
