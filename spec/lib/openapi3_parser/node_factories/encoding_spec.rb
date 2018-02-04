# frozen_string_literal: true

require "openapi3_parser/node_factories/encoding"
require "openapi3_parser/node/encoding"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactories::Encoding do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Encoding do
    let(:input) do
      {
        "contentType" => "image/png, image/jpeg",
        "headers" => {
          "X-Rate-Limit-Limit" => {
            "description" => "The number of allowed requests in the current "\
                             "period",
            "schema" => { "type" => "integer" }
          }
        }
      }
    end

    let(:context) { create_context(input) }
  end
end
