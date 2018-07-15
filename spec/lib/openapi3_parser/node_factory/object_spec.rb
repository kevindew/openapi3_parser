# frozen_string_literal: true

require "openapi3_parser/error"
require "openapi3_parser/node_factory/object"

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Object do
  include Helpers::Context
  let(:context) { create_context({}) }
  let(:instance) { described_class.new(context) }

  it_behaves_like "node factory", ::Hash
end
