# frozen_string_literal: true

require "openapi3_parser/node_factory/info"
require "openapi3_parser/node/info"

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Info do
  include Helpers::Context
  let(:minimal_info_definition) do
    {
      "title" => "Info",
      "version" => "1.0"
    }
  end

  it_behaves_like "node object factory", Openapi3Parser::Node::Info do
    let(:input) do
      minimal_info_definition.merge(
        "license" => { "name" => "License" },
        "contact" => { "name" => "Contact" }
      )
    end

    let(:context) { create_context(input) }
  end

  describe "terms of service" do
    subject(:factory) { described_class.new(context) }
    let(:input) do
      minimal_info_definition.merge("termsOfService" => terms_of_service)
    end
    let(:context) { create_context(input) }

    context "when terms of service is a url" do
      let(:terms_of_service) { "https://example.com/path" }
      it { is_expected.to be_valid }
    end

    context "when terms of service is not a url" do
      let(:terms_of_service) { "not a url" }
      it { is_expected.not_to be_valid }
    end
  end
end
