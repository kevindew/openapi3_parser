# frozen_string_literal: true

require "openapi3_parser/node_factories/external_documentation"
require "openapi3_parser/nodes/external_documentation"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::ExternalDocumentation do
  include Helpers::Context

  it_behaves_like "node object factory",
                  Openapi3Parser::Nodes::ExternalDocumentation do
    let(:input) do
      {
        "description" => "Test",
        "url" => "http://www.yahoo.com"
      }
    end

    let(:context) { create_context(input) }
  end
end
