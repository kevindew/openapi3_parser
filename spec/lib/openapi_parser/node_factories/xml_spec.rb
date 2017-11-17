# frozen_string_literal: true

require "openapi_parser/node_factories/xml"
require "openapi_parser/nodes/xml"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::Xml do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Xml do
    let(:input) do
      {
        "namespace" => "http://example.com/schema/sample",
        "prefix" => "sample"
      }
    end

    let(:context) { create_context(input) }
  end
end
