# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::PathItem do
  describe "#alternative_servers?" do
    it "returns true when this node has it's own servers" do
      node = create_node([{ "url" => "https://example.com" }])

      expect(node.alternative_servers?).to be true
    end

    it "returns false when this node hasn't got it's own servers" do
      node = create_node(nil)

      expect(node.alternative_servers?).to be false
    end
  end

  def create_node(servers)
    input = { "servers" => servers }

    factory_context = create_node_factory_context(
      input,
      document_input: {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Minimal Openapi definition",
          "version" => "1.0.0"
        },
        "paths" => { "/test" => { "get" => input } }
      },
      pointer_segments: %w[paths /test get]
    )

    Openapi3Parser::NodeFactory::PathItem
      .new(factory_context)
      .node(node_factory_context_to_node_context(factory_context))
  end
end
