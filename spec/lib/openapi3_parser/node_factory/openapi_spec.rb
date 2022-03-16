# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Openapi do
  let(:minimal_openapi_definition) do
    {
      "openapi" => "3.0.0",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {}
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Openapi do
    let(:input) { minimal_openapi_definition }
  end

  context "when input is nil" do
    let(:factory_context) { create_node_factory_context(nil) }

    it "is invalid" do
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("Invalid type. Expected Object")
    end

    it "raises an error trying to access the node" do
      instance = described_class.new(factory_context)
      node_context = node_factory_context_to_node_context(factory_context)
      expect { instance.node(node_context) }.to raise_error(Openapi3Parser::Error)
    end
  end

  describe "validating tags" do
    it "is valid when tags contain no duplicates" do
      factory_context = create_node_factory_context(
        minimal_openapi_definition.merge(
          "tags" => [{ "name" => "a" }, { "name" => "b" }]
        )
      )
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an invalid key" do
      factory_context = create_node_factory_context(
        minimal_openapi_definition.merge(
          "tags" => [{ "name" => "a" }, { "name" => "a" }]
        )
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/tags")
        .with_message("Duplicate tag names: a")
    end
  end

  describe "default values for servers" do
    it "contains a basic root server when servers input is nil" do
      node = create_node(minimal_openapi_definition.merge({ "servers" => nil }))
      expect(node["servers"].length).to be 1
      expect(node["servers"][0].url).to eq "/"
      expect(node["servers"][0].description).to be_nil
    end

    it "contains a basic root server when servers input is an empty array" do
      node = create_node(minimal_openapi_definition.merge({ "servers" => [] }))
      expect(node["servers"].length).to be 1
      expect(node["servers"][0].url).to eq "/"
      expect(node["servers"][0].description).to be_nil
    end

    it "uses the defined servers when they are provided" do
      node = create_node(
        minimal_openapi_definition.merge(
          {
            "servers" => [
              {
                "url" => "https://prod.example.com/v1",
                "description" => "Production server"
              }
            ]
          }
        )
      )

      expect(node["servers"][0].url).to eq "https://prod.example.com/v1"
      expect(node["servers"][0].description).to eq "Production server"
    end
  end

  describe "webhooks field" do
    it "accepts this field for OpenAPI >= 3.1" do
      factory_context = create_node_factory_context(
        {
          "openapi" => "3.1.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "webhooks" => {}
        },
        document_input: { "openapi" => "3.1.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).to be_valid
    end

    it "rejects this field for OpenAPI < 3.1" do
      factory_context = create_node_factory_context(
        {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "webhooks" => {}
        },
        document_input: { "openapi" => "3.0.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
    end
  end

  describe "OpenAPI version 3.1" do
    it "is valid without the paths parameter" do
      factory_context = create_node_factory_context(
        {
          "openapi" => "3.1.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          }
        },
        document_input: { "openapi" => "3.1.0" }
      )

      instance = described_class.new(factory_context)
      expect(instance).to be_valid
    end
  end

  def create_node(input)
    node_factory_context = create_node_factory_context(input)
    instance = described_class.new(node_factory_context)
    node_context = node_factory_context_to_node_context(node_factory_context)
    instance.node(node_context)
  end
end
