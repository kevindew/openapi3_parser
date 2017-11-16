# frozen_string_literal: true

require "openapi_parser/nodes/license/factory"
require "openapi_parser/nodes/license"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::Nodes::License::Factory do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::License do
    let(:input) do
      {
        "name" => "License"
      }
    end

    let(:context) { create_context(input) }
  end
end
