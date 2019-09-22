# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Server do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Server do
    let(:input) do
      {
        "url" => "https://{username}.gigantic-server.com:{port}/{basePath}",
        "description" => "The production API server",
        "variables" => {
          "username" => {
            "default" => "demo",
            "description" => "this value is assigned by the service provider,"\
                             "in this example `gigantic-server.com`"
          },
          "port" => {
            "enum" => %w[8443 443],
            "default" => "8443"
          },
          "basePath" => {
            "default" => "v2"
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end
end
