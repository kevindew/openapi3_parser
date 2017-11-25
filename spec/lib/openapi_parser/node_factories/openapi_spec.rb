# frozen_string_literal: true

require "openapi_parser/node_factories/openapi"
require "openapi_parser/nodes/openapi"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Openapi do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Openapi do
    let(:input) do
      {
        "openapi" => "3.0.0",
        "info" => {
          "title" => "Minimal Openapi definition",
          "version" => "1.0.0"
        },
        "paths" => {}
      }
    end

    let(:context) { create_context(input) }
  end
end
