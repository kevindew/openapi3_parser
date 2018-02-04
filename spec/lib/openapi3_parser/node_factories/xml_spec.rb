# frozen_string_literal: true

require "openapi3_parser/node_factories/xml"
require "openapi3_parser/node/xml"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Xml do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Xml do
    let(:input) do
      {
        "namespace" => "http://example.com/schema/sample",
        "prefix" => "sample"
      }
    end

    let(:context) { create_context(input) }
  end
end
