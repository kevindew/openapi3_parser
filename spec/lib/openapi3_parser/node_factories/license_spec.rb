# frozen_string_literal: true

require "openapi3_parser/node_factories/license"
require "openapi3_parser/nodes/license"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::License do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Nodes::License do
    let(:input) do
      {
        "name" => "License"
      }
    end

    let(:context) { create_context(input) }
  end
end
