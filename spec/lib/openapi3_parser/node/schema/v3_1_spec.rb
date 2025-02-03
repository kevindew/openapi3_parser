# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Schema::V3_1 do
  it_behaves_like "schema node", openapi_version: "3.1.0"

  shared_examples "schema presence boolean" do |method_name, property|
    describe "##{method_name}" do
      let(:factory_context) do
        create_node_factory_context(
          { property => schema },
          document_input: {
            "openapi" => "3.1.0",
            "info" => {
              "title" => "Minimal Openapi definition",
              "version" => "1.0.0"
            }
          }
        )
      end

      let(:instance) do
        Openapi3Parser::NodeFactory::Schema::V3_1
          .new(factory_context)
          .node(node_factory_context_to_node_context(factory_context))
      end

      context "when a schema object is provided" do
        let(:schema) { { "type" => "string" } }

        it "returns true" do
          expect(instance.public_send(method_name)).to be(true)
        end
      end

      context "when a schema of true is provided" do
        let(:schema) { true }

        it "returns true" do
          expect(instance.public_send(method_name)).to be(true)
        end
      end

      context "when a schema of false is provided" do
        let(:schema) { false }

        it "returns false" do
          expect(instance.public_send(method_name)).to be(false)
        end
      end

      context "when no schema is provided" do
        let(:schema) { nil }

        it "returns false" do
          expect(instance.public_send(method_name)).to be(false)
        end
      end
    end
  end

  shared_examples "ruby keyword method" do |method_name|
    describe "##{method_name}" do
      it "supports a Ruby reserved word as a method name" do
        factory_context = create_node_factory_context(
          { method_name.to_s => { "type" => "string" } },
          document_input: {
            "openapi" => "3.1.0",
            "info" => {
              "title" => "Minimal Openapi definition",
              "version" => "1.0.0"
            }
          }
        )

        instance = Openapi3Parser::NodeFactory::Schema::V3_1
                   .new(factory_context)
                   .node(node_factory_context_to_node_context(factory_context))

        expect(instance.public_send(method_name))
          .to be_an_instance_of(described_class)
      end
    end
  end

  describe "boolean methods" do
    let(:instance) do
      factory_context = create_node_factory_context(input)

      Openapi3Parser::NodeFactory::Schema::V3_1
        .new(factory_context)
        .node(node_factory_context_to_node_context(factory_context))
    end

    context "when given a boolean schema with a true value" do
      let(:input) { true }

      it "identifies as a boolean" do
        expect(instance.boolean?).to be(true)
        expect(instance.boolean).to be(true)
        expect(instance.true?).to be(true)
        expect(instance.false?).to be(false)
      end
    end

    context "when given a boolean schema with a false value" do
      let(:input) { false }

      it "identifies as a boolean" do
        expect(instance.boolean?).to be(true)
        expect(instance.boolean).to be(false)
        expect(instance.true?).to be(false)
        expect(instance.false?).to be(true)
      end
    end

    context "when given an object schema" do
      let(:input) { { "type" => "string" } }

      it "does not identify as a boolean" do
        expect(instance.boolean?).to be(false)
        expect(instance.boolean).to be_nil
        expect(instance.true?).to be(false)
        expect(instance.false?).to be(false)
      end
    end
  end

  include_examples "schema presence boolean", :additional_properties?, "additionalProperties"
  include_examples "schema presence boolean", :unevaluated_items?, "unevaluatedItems"
  include_examples "schema presence boolean", :unevaluated_properties?, "unevaluatedProperties"

  include_examples "ruby keyword method", :if
  include_examples "ruby keyword method", :then
  include_examples "ruby keyword method", :else
end
