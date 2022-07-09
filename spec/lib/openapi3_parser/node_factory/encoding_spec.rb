# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Encoding do
  it_behaves_like "node object factory", Openapi3Parser::Node::Encoding do
    let(:input) do
      {
        "contentType" => "image/png, image/jpeg",
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current " \
                             "period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end
  end

  describe "default value for explode" do
    it "sets explode to true when style is 'form'" do
      factory_context = create_node_factory_context({ "style" => "form" })
      node = described_class.new(factory_context).node(
        node_factory_context_to_node_context(factory_context)
      )
      expect(node["explode"]).to be(true)
    end

    it "sets explode to false when style is not 'form'" do
      factory_context = create_node_factory_context({ "style" => "simple" })
      node = described_class.new(factory_context).node(
        node_factory_context_to_node_context(factory_context)
      )
      expect(node["explode"]).to be(false)
    end
  end
end
