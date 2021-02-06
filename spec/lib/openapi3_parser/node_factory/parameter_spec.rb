# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Parameter do
  it_behaves_like "node object factory", Openapi3Parser::Node::Parameter do
    let(:input) do
      {
        "name" => "id",
        "in" => "query",
        "description" => "ID of the object to fetch",
        "required" => false,
        "schema" => {
          "type" => "array",
          "items" => {
            "type" => "string"
          }
        },
        "style" => "form",
        "explode" => true,
        "examples" => {
          "example_name" => {
            "value" => [1, 2]
          }
        }
      }
    end
  end

  it_behaves_like "mutually exclusive example" do
    let(:input) { { "name" => "name", "in" => "query" } }
  end

  describe "validating in field" do
    it "is valid for 'query', 'header', 'path', or 'cookie'" do
      %w[query header path cookie].each do |in_value|
        factory_context = create_node_factory_context({ "name" => "name",
                                                        "in" => in_value,
                                                        "required" => true })
        expect(described_class.new(factory_context)).to be_valid
      end
    end

    it "is invalid for a different value" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "different",
                                                      "required" => true })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/in")
        .with_message("in can only be header, query, cookie, or path")
    end
  end

  describe "validating required field" do
    it "is valid when in is 'path' and required is true" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "path",
                                                      "required" => true })
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid when in is 'path' and required is false" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "path",
                                                      "required" => false })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/required")
        .with_message("Must be included and true for a path parameter")
    end

    it "is invalid when in is 'path' and required is ommitted" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "path" })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/required")
    end
  end

  describe "default style value" do
    it "has a value of 'simple' for an in of 'path'" do
      node = create_node({ "name" => "name", "in" => "path", "required" => true })
      expect(node["style"]).to eq("simple")
    end

    it "has a value of 'simple' for an in of 'header'" do
      node = create_node({ "name" => "name", "in" => "header", "required" => true })
      expect(node["style"]).to eq("simple")
    end

    it "has a value of 'form' for an in of 'query'" do
      node = create_node({ "name" => "name", "in" => "query", "required" => true })
      expect(node["style"]).to eq("form")
    end
  end

  describe "default explode value" do
    it "has a value of true when style is 'form'" do
      node = create_node({ "name" => "name", "in" => "query", "style" => "form" })
      expect(node["explode"]).to be(true)
    end

    it "has a value of false when style is 'simple'" do
      node = create_node({ "name" => "name", "in" => "query", "style" => "simple" })
      expect(node["explode"]).to be(false)
    end
  end

  describe "validating content field" do
    let(:message) { "Must only have one item" }

    it "is valid with a nil value for content" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "query",
                                                      "content" => nil })
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for an empty content object" do
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "query",
                                                      "content" => {} })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/content").with_message(message)
    end

    it "is valid for a single content definition" do
      content = { "media_type" => { "schema" => { "type" => "string" } } }
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "query",
                                                      "content" => content })
      expect(described_class.new(factory_context)).to be_valid
    end

    it "is invalid for multiple content definitions" do
      content = {
        "media_type_1" => { "schema" => { "type" => "string" } },
        "media_type_2" => { "schema" => { "type" => "string" } }
      }
      factory_context = create_node_factory_context({ "name" => "name",
                                                      "in" => "query",
                                                      "content" => content })
      instance = described_class.new(factory_context)
      expect(instance).not_to be_valid
      expect(instance).to have_validation_error("#/content").with_message(message)
    end
  end

  def create_node(fields = {})
    factory_context = create_node_factory_context(fields)
    described_class.new(factory_context).node(
      node_factory_context_to_node_context(factory_context)
    )
  end
end
