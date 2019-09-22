# frozen_string_literal: true

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Object do
  include Helpers::Context
  let(:node_factory_context) { create_node_factory_context({}) }
  let(:instance) { described_class.new(node_factory_context) }

  it_behaves_like "node factory", ::Hash
end
