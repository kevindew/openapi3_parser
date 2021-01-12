# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Responses do
  it_behaves_like "node object factory", Openapi3Parser::Node::Responses do
    let(:input) do
      {
        "200" => {
          "description" => "a pet to be returned",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        },
        "default" => {
          "description" => "Unexpected error",
          "content" => {
            "application/json" => {
              "schema" => { "type" => "string" }
            }
          }
        }
      }
    end
  end

  describe "validating keys" do
    let(:response) do
      {
        "description" => "A response",
        "content" => {
          "application/json" => {
            "schema" => { "type" => "string" }
          }
        }
      }
    end

    it "is valid when the key is 'default'" do
      instance = described_class.new(
        create_node_factory_context({ "default" => response })
      )
      expect(instance).to be_valid
    end

    it "is valid when the key is a status code range" do
      instance = described_class.new(
        create_node_factory_context({ "2XX" => response })
      )
      expect(instance).to be_valid
    end

    it "is valid when the key is a valid status code" do
      instance = described_class.new(
        create_node_factory_context({ "503" => response })
      )
      expect(instance).to be_valid
    end

    it "is invalid when the key is an invalid status code" do
      instance = described_class.new(
        create_node_factory_context({ "999" => response })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message(
          "Invalid responses keys: '999' - default, status codes and status code ranges allowed"
        )
    end

    it "is invalid when the key is not a status code od default" do
      instance = described_class.new(
        create_node_factory_context({ "any string" => response })
      )
      expect(instance).not_to be_valid
    end
  end
end
