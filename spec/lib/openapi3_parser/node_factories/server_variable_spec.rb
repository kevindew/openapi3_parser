# frozen_string_literal: true

require "openapi3_parser/node_factories/server_variable"
require "openapi3_parser/node/server_variable"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::ServerVariable do
  include Helpers::Context

  it_behaves_like "node object factory",
                  Openapi3Parser::Node::ServerVariable do
    let(:input) do
      {
        "enum" => %w[8443 443],
        "default" => "8443"
      }
    end

    let(:context) { create_context(input) }
  end
end
