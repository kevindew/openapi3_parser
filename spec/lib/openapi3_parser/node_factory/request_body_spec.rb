# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::RequestBody do
  it_behaves_like "node object factory", Openapi3Parser::Node::RequestBody do
    let(:input) do
      {
        "description" => "user to add to the system",
        "content" => {
          "text/plain" => {
            "schema" => {
              "type" => "array",
              "items" => { "type" => "string" }
            }
          }
        }
      }
    end
  end

  describe "validating content" do
    it "is valid when content has a valid media type" do
      instance = described_class.new(
        create_node_factory_context({ "content" => { "application/json" => {} } })
      )
      expect(instance).to be_valid
    end

    it "is valid when content has a valid media type range" do
      instance = described_class.new(
        create_node_factory_context({ "content" => { "text/*" => {} } })
      )
      expect(instance).to be_valid
    end

    it "is invalid when content has an invalid media type" do
      instance = described_class.new(
        create_node_factory_context({ "content" => { "bad-media-type" => {} } })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/content/bad-media-type")
        .with_message(%("bad-media-type" is not a valid media type))
    end

    it "is invalid when content is an empty hash" do
      instance = described_class.new(create_node_factory_context({ "content" => {} }))
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/content")
        .with_message("Expected to have at least 1 item")
    end
  end

  describe "required field" do
    it "defaults to false" do
      factory_context = create_node_factory_context(
        { "content" => { "application/json" => {} } }
      )
      node = described_class.new(factory_context).node(
        node_factory_context_to_node_context(factory_context)
      )
      expect(node["required"]).to be(false)
    end
  end
end
