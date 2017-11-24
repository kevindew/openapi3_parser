# frozen_string_literal: true

require "openapi_parser/node_factories/security_requirement"
require "openapi_parser/nodes/security_requirement"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::NodeFactories::SecurityRequirement do
  include Helpers::Context

  it_behaves_like "node object factory",
                  OpenapiParser::Nodes::SecurityRequirement do
    let(:input) do
      {
        "petstore_auth" => %w[write:pets read:pets]
      }
    end

    let(:context) { create_context(input) }
  end
end
