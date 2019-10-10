# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Node::Schema do
  include Helpers::Context

  describe "#name" do
    subject { described_class.new({}, node_context).name }

    context "when the schema source location is a group of schemas" do
      let(:node_context) do
        create_node_context({}, pointer_segments: %w[components schemas Pet])
      end

      it { is_expected.to eq "Pet" }
    end

    context "when the schema source location is not a group of schemas" do
      let(:node_context) do
        create_node_context(
          {},
          pointer_segments: %w[content application/json schema]
        )
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#requires?" do
    let(:instance) do
      factory_context = create_node_factory_context(input)

      Openapi3Parser::NodeFactory::Schema
        .new(factory_context)
        .node(node_factory_context_to_node_context(factory_context))
    end

    context "when required is not set" do
      let(:input) do
        {
          "type" => "object",
          "properties" => {
            "field" => { "type" => "string" }
          }
        }
      end

      it "returns false" do
        expect(instance.requires?("field")).to be false
      end
    end

    context "when required is set" do
      let(:input) do
        {
          "type" => "object",
          "required" => %w[field_a],
          "properties" => {
            "field_a" => { "type" => "string" },
            "field_b" => { "type" => "string" }
          }
        }
      end

      it "is true for a required property name" do
        expect(instance.requires?("field_a")).to be true
      end

      it "is false for a non required property name" do
        expect(instance.requires?("field_b")).to be false
      end

      it "is false for a missing property" do
        expect(instance.requires?("field_c")).to be false
      end

      it "is true for a required property schema" do
        schema = instance.properties["field_a"]
        expect(instance.requires?(schema)).to be true
      end

      it "is false for a non required property schema" do
        schema = instance.properties["field_b"]
        expect(instance.requires?(schema)).to be false
      end
    end
  end
end
