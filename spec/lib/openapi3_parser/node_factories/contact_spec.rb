# frozen_string_literal: true

require "openapi3_parser/node_factories/contact"
require "openapi3_parser/nodes/contact"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Contact do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Nodes::Contact do
    let(:input) do
      {
        "name" => "Contact"
      }
    end

    let(:context) { create_context(input) }
  end
end
