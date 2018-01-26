# frozen_string_literal: true

require "openapi3_parser/validation/error"
require "openapi3_parser/validation/error_collection"

require "support/helpers/context"

RSpec.describe Openapi3Parser::Validation::Error do
  include Helpers::Context

  describe ".for_type" do
    subject { described_class.new(message, context, factory_class).for_type }
    let(:message) { "" }
    let(:context) { create_context({}) }

    context "when factory_class is nil" do
      let(:factory_class) { nil }

      it { is_expected.to be_nil }
    end

    context "when factory_class is a root class name" do
      class Test; end
      let(:factory_class) { ::Test }

      it { is_expected.to eq "Test" }
    end

    context "when factory_class is within a namespace" do
      module Example
        class Nested; end
      end
      let(:factory_class) { Example::Nested }

      it { is_expected.to eq "Nested" }
    end
  end
end
