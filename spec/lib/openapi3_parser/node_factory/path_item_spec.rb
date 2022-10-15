# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::PathItem do
  # TODO: perhaps a behaves like referenceable node object factory?

  it_behaves_like "node object factory", Openapi3Parser::Node::PathItem do
    let(:input) do
      {
        "summary" => "Example",
        "get" => {
          "description" => "Returns pets based on ID",
          "summary" => "Find pets by ID",
          "operationId" => "getPetsById",
          "responses" => {
            "200" => {
              "description" => "pet response",
              "content" => {
                "*/*" => {
                  "schema" => {
                    "type" => "array",
                    "items" => { "type" => "string" }
                  }
                }
              }
            },
            "default" => {
              "description" => "error payload",
              "content" => {
                "text/html" => {
                  "schema" => { "type" => "string" }
                }
              }
            }
          }
        },
        "parameters" => [
          {
            "name" => "id",
            "in" => "path",
            "description" => "ID of pet to use",
            "required" => true,
            "schema" => {
              "type" => "array",
              "items" => {
                "type" => "string"
              }
            },
            "style" => "simple"
          }
        ],
        "servers" => [
          {
            "url" => "https://development.gigantic-server.com/v1",
            "description" => "Development server"
          }
        ]
      }
    end
  end

  describe "validating parameters" do
    it "is valid when there aren't duplicate parameters" do
      input = {
        "parameters" => [
          { "name" => "id", "in" => "header" },
          { "name" => "id", "in" => "query" }
        ]
      }
      instance = described_class.new(create_node_factory_context(input))

      expect(instance).to be_valid
    end

    it "is invalid when there are duplicate parameters" do
      input = {
        "parameters" => [
          { "name" => "id", "in" => "query" },
          { "name" => "id", "in" => "query" }
        ]
      }
      instance = described_class.new(create_node_factory_context(input))

      expect(instance).not_to be_valid
    end
  end

  describe "merging contents with a reference" do
    let(:document_input) do
      {
        "path_items" => {
          "example" => {
            "summary" => "My summary",
            "parameters" => [
              { "name" => "id", "in" => "query" }
            ],
            "servers" => [{ "url" => "/" }]
          }
        }
      }
    end

    context "when the input is only a reference" do
      let(:input) { { "$ref" => "#/path_items/example" } }

      it "includes the reference data in the resolved_input" do
        factory_context = create_node_factory_context(
          input, document_input: document_input
        )
        expect(described_class.new(factory_context).resolved_input).to match(
          hash_including(
            "summary" => "My summary",
            "parameters" => [
              hash_including("name" => "id", "in" => "query")
            ]
          )
        )
      end

      it "uses the reference data in the node" do
        node = create_node(input, document_input)
        expect(node.summary).to eq "My summary"
        expect(node.parameters[0].name).to eq "id"
      end
    end

    context "when the input includes fields besides a reference" do
      let(:input) do
        { "$ref" => "#/path_items/example", "summary" => "A different summary" }
      end

      it "overwrites reference data with input data" do
        node = create_node(input, document_input)
        expect(node.summary).to eq "A different summary"
      end
    end
  end

  describe "default values for servers" do
    let(:document_input) do
      {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Minimal Openapi definition",
          "version" => "1.0.0"
        },
        "paths" => {},
        "servers" => [
          {
            "url" => "https://dev.example.com/v1",
            "description" => "Development server"
          }
        ]
      }
    end

    it "uses the root object servers when servers is nil" do
      node = create_node({ "servers" => nil }, document_input)
      expect(node["servers"][0].url).to eq "https://dev.example.com/v1"
      expect(node["servers"][0].description).to eq "Development server"
    end

    it "uses the root object servers when servers is an empty array" do
      node = create_node({ "servers" => [] }, document_input)
      expect(node["servers"][0].url).to eq "https://dev.example.com/v1"
      expect(node["servers"][0].description).to eq "Development server"
    end

    it "uses the defined servers when they are provided" do
      node = create_node(
        {
          "servers" => [
            {
              "url" => "https://prod.example.com/v1",
              "description" => "Production server"
            }
          ]
        },
        document_input
      )

      expect(node["servers"][0].url).to eq "https://prod.example.com/v1"
      expect(node["servers"][0].description).to eq "Production server"
    end
  end

  def create_node(input, document_input)
    node_factory_context = create_node_factory_context(input, document_input: document_input)
    instance = described_class.new(node_factory_context)
    node_context = node_factory_context_to_node_context(node_factory_context)
    instance.node(node_context)
  end
end
