# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Openapi do
  include Helpers::Context
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
    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  context "when input is nil" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:input) { nil }
    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end

    it { is_expected.to_not be_valid }
    it "raises error accessing node" do
      expect { subject.node(node_context) }
        .to raise_error(Openapi3Parser::Error)
    end
  end

  describe "tags" do
    subject(:factory) { described_class.new(node_factory_context) }
    let(:input) { minimal_openapi_definition.merge("tags" => tags) }
    let(:node_factory_context) { create_node_factory_context(input) }

    context "when tags contains no duplicate names" do
      let(:tags) do
        [
          { "name" => "a" }
        ]
      end
      it { is_expected.to be_valid }
    end

    context "when tags contains duplicate names" do
      let(:tags) do
        [
          { "name" => "a" },
          { "name" => "a" }
        ]
      end
      it { is_expected.not_to be_valid }

      it "has a duplicate tags names error" do
        message = "Duplicate tag names: a"
        expect(factory.errors.first.message).to eq message
      end
    end
  end

  describe "servers" do
    subject(:node) do
      input = minimal_openapi_definition.merge("servers" => servers)
      node_factory_context = create_node_factory_context(input)
      node_context = node_factory_context_to_node_context(node_factory_context)
      described_class.new(node_factory_context)
                     .node(node_context)
    end

    shared_examples "defaults to a single root server" do
      # As per: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#fixed-fields
      it "has an array with a root server" do
        servers = node["servers"]
        expect(servers.length).to be 1
        expect(servers[0]).to be_a(Openapi3Parser::Node::Server)
        expect(servers[0].url).to eq "/"
        expect(servers[0].description).to be_nil
      end
    end

    context "when servers are not provided" do
      let(:servers) { nil }

      include_examples "defaults to a single root server"
    end

    # context "when servers are an empty array" do
    #   let(:servers) { [] }
    #
    #   include_examples "defaults to a single root server"
    # end

    context "when servers are set" do
      let(:servers) do
        [
          {
            "url" => "https://development.gigantic-server.com/v1",
            "description" => "Development server"
          }
        ]
      end

      it "has an array with the server value" do
        servers = node["servers"]
        expect(servers.length).to be 1
        expect(servers[0]).to be_a(Openapi3Parser::Node::Server)
        expect(servers[0].description).to eq "Development server"
      end
    end
  end
end
