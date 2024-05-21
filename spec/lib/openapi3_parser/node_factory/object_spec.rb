# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Object do
  let(:node_factory_context) { create_node_factory_context({}) }
  let(:instance) { described_class.new(node_factory_context) }

  it_behaves_like "node factory", Hash
end
