# frozen_string_literal: true

require "openapi_parser/nodes/contact/factory"
require "openapi_parser/nodes/contact"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe OpenapiParser::Nodes::Contact::Factory do
  include Helpers::Context

  it_behaves_like "node object factory", OpenapiParser::Nodes::Contact do
    let(:input) do
      {
        "name" => "Contact"
      }
    end

    let(:context) { create_context(input) }
  end
end
