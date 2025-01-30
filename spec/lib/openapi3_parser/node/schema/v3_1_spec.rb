# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Schema::V3_1 do
  it_behaves_like "schema node", openapi_version: "3.1.0"

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

  %i[if then else].each do |method_name|
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
end
