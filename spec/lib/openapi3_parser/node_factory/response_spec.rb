# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Response do
  let(:minimal_definition) do
    { "description" => "Description" }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Response do
    let(:input) do
      {
        "description" => "A simple string response",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "string"
            }
          }
        },
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Remaining" => {
            "description" => "The number of remaining requests in the current period",
            "schema" => { "type" => "integer" }
          },
          "X-Rate-Limit-Reset" => {
            "description" => "The number of seconds left in the current period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end
  end

  describe "validating content" do
    it "is valid when content is an empty hash" do
      instance = described_class.new(
        create_node_factory_context(
          minimal_definition.merge({ "content" => {} })
        )
      )
      expect(instance).to be_valid
    end

    it "is valid when content has a valid media type" do
      instance = described_class.new(
        create_node_factory_context(
          minimal_definition.merge({ "content" => { "application/json" => {} } })
        )
      )
      expect(instance).to be_valid
    end

    it "is invalid when content has an invalid media type" do
      instance = described_class.new(
        create_node_factory_context(
          minimal_definition.merge({ "content" => { "bad-media-type" => {} } })
        )
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/content/bad-media-type")
        .with_message(%("bad-media-type" is not a valid media type))
    end
  end

  describe "validating links keys" do
    let(:link) { { "operationRef" => "#/test" } }

    it "is valid for a key that matches the expected formatting" do
      instance = described_class.new(
        create_node_factory_context(
          minimal_definition.merge(
            { "links" => { "valid.key" => link } }
          )
        )
      )
      expect(instance).to be_valid
    end

    it "is invalid for a key that doesn't match the expected formatting" do
      instance = described_class.new(
        create_node_factory_context(
          minimal_definition.merge(
            { "links" => { "Invalid Key" => link } }
          )
        )
      )
      expect(instance).not_to be_valid
    end
  end
end
