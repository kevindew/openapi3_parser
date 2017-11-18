# frozen_string_literal: true

require "openapi_parser/node_factories/server"
require "openapi_parser/nodes/server"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Server do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Server do
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
