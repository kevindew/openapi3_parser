# frozen_string_literal: true

require "openapi3_parser/node/object"
require "openapi3_parser/node/openapi"
require "openapi3_parser/node/paths"

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::Object do
  include Helpers::Context

  describe "#node_at" do
    subject { described_class.new(data, context).node_at(pointer) }

    let(:data) { {} }
    let(:context) do
      create_context(
        {},
        document_input: {
          "openapi" => "3.0.0",
          "info" => {
            "title" => "Minimal Openapi definition",
            "version" => "1.0.0"
          },
          "paths" => {}
        },
        pointer_segments: %w[info]
      )
    end

    context "when a absolute path is specified" do
      let(:pointer) { "#/paths" }

      it { is_expected.to be_instance_of(Openapi3Parser::Node::Paths) }
    end

    context "when a relative path is specified" do
      let(:pointer) { "#version" }

      it { is_expected.to eq "1.0.0" }
    end

    context "when a .. path is specified" do
      let(:pointer) { "#.." }

      it { is_expected.to be_instance_of(Openapi3Parser::Node::Openapi) }
    end
  end
end
