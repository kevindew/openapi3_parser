# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Paths do
  it_behaves_like "node object factory", Openapi3Parser::Node::Paths do
    let(:input) do
      {
        "/pets" => {
          "get" => {
            "description" => "Returns all pets that the user has access to",
            "responses" => {
              "200" => {
                "description" => "A list of pets.",
                "content" => {
                  "application/json" => {
                    "schema" => {
                      "type" => "array",
                      "items" => { "type" => "string" }
                    }
                  }
                }
              }
            }
          }
        }
      }
    end
  end

  describe "validating path keys" do
    let(:path) do
      {
        "get" => {
          "description" => "Description",
          "responses" => {
            "200" => { "description" => "Description" }
          }
        }
      }
    end

    it "is valid when the path key is a valid path" do
      instance = described_class.new(create_node_factory_context({ "/path" => path }))
      expect(instance).to be_valid
    end

    it "is valid when the path key has template parameters" do
      instance = described_class.new(
        create_node_factory_context({ "/path/{test}" => path })
      )
      expect(instance).to be_valid
    end

    it "is invalid when the path isn't prefixed with a slash" do
      instance = described_class.new(
        create_node_factory_context({ "path" => path })
      )
      expect(instance).not_to be_valid
    end

    it "is invalid when the path isn't a valid path" do
      instance = described_class.new(
        create_node_factory_context({ "invalid path" => path })
      )
      expect(instance).not_to be_valid
    end

    it "is invalid when there are two paths with same hiearchy but different templated names" do
      factory_context = create_node_factory_context({ "/path/{param_a}/test" => path,
                                                      "/path/{param_b}/test" => path })
      expect(described_class.new(factory_context)).not_to be_valid
    end
  end
end
