# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Object do
  describe "#node_at" do
    let(:instance) { described_class.new(data, context) }
    let(:data) { {} }
    let(:context) do
      create_node_context(
        {},
        document_input: {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "paths" => {}
        },
        pointer_segments: %w[info]
      )
    end

    it "can find a node via an absolute path" do
      expect(instance.node_at("#/paths"))
        .to be_instance_of(Openapi3Parser::Node::Paths)
    end

    it "can find a node via a relative path" do
      expect(instance.node_at("#version")).to eq "1.0.0"
    end

    it "can use '..' to access the parent node" do
      expect(instance.node_at("#.."))
        .to be_instance_of(Openapi3Parser::Node::Openapi)
    end
  end

  it_behaves_like "node equality", {}

  describe "#values" do
    it "returns an array of values" do
      instance = described_class.new({ "a" => "value_a", "b" => "value_b" },
                                     create_node_context({}))

      expect(instance.values).to eq %w[value_a value_b]
    end
  end
end
