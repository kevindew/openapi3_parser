# frozen_string_literal: true

require "openapi_parser/node_factories/info"
require "openapi_parser/nodes/info"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Info do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Info do
    let(:input) do
      {
        "title" => "Info",
        "license" => { "name" => "License" },
        "contact" => { "name" => "Contact" },
        "version" => "1.0"
      }
    end

    let(:context) { create_context(input) }
  end
end
