# frozen_string_literal: true

require "openapi3_parser/node_factory/server"
require "openapi3_parser/node/server"

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

    let(:context) { create_context(input) }
  end
end
