# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Schema::V3_0 do
  it_behaves_like "schema node", openapi_version: "3.0.0"
end
