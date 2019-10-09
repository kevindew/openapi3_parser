# frozen_string_literal: true

require "support/node_equality"

RSpec.describe Openapi3Parser::Node::Array do
  include Helpers::Context

  it_behaves_like "node equality", []
end
