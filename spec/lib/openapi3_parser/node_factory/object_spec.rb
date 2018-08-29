# frozen_string_literal: true

require "support/helpers/context"
require "support/node_factory"

RSpec.describe Openapi3Parser::NodeFactory::Object do
  include Helpers::Context
  let(:context) { create_context({}) }
  let(:instance) { described_class.new(context) }

  it_behaves_like "node factory", ::Hash
end
