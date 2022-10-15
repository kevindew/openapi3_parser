# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::ResolvedInputBuilder do
  describe ".call" do
    context "when a factory doesn't have references" do
      it "returns the objects data" do
        factory_context = create_node_factory_context({ "field" => "value" })
        factory = Openapi3Parser::NodeFactory::Object.new(factory_context)

        expect(described_class.call(factory)).to eq({ "field" => "value" })
      end

      it "returns nil for a factory with nil data" do
        factory_context = create_node_factory_context(nil)
        factory = Openapi3Parser::NodeFactory::Object.new(factory_context)

        expect(described_class.call(factory)).to be_nil
      end
    end

    context "when a factory has references" do
      let(:factory_class) do
        Class.new(Openapi3Parser::NodeFactory::Object) do
          include Openapi3Parser::NodeFactory::Referenceable

          field "$ref", factory: :ref_factory
          field "first_name"
          field "last_name"

          def ref_factory(context)
            Openapi3Parser::NodeFactory::Fields::Reference.new(context, self.class)
          end
        end
      end

      it "merges data from factories together" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/reference_a" },
          document_input: {
            "reference_a" => { "$ref" => "#/reference_b", "last_name" => "Smith" },
            "reference_b" => { "first_name" => "John", "last_name" => "Doe" }
          }
        )
        factory = factory_class.new(factory_context)

        expect(described_class.call(factory))
          .to include({ "first_name" => "John", "last_name" => "Smith" })
      end

      it "removes $ref fields" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/reference_a" },
          document_input: {
            "reference_a" => { "first_name" => "John", "last_name" => "Smith" }
          }
        )
        factory = factory_class.new(factory_context)

        expect(described_class.call(factory).keys).not_to include("$ref")
      end

      it "allows fields to be overriden with nil" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/reference_a", "last_name" => nil },
          document_input: {
            "reference_a" => { "first_name" => "John", "last_name" => "Smith" }
          }
        )
        factory = factory_class.new(factory_context)

        expect(described_class.call(factory))
          .to match({ "first_name" => "John" })
      end

      it "returns nil if a factory reference doesn't resolve" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/reference_a" },
          document_input: {
            "reference_a" => { "$ref" => "#/reference_b" },
            "reference_b" => { "$ref" => "#/reference_a" }
          }
        )

        factory = factory_class.new(factory_context)

        expect(described_class.call(factory)).to be_nil
      end

      it "returns a RecursiveResolvedInput object for node data that is in a recursive loop" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Reference" },
          document_input: {
            "components" => {
              "schemas" => {
                "Reference" => {
                  "type" => "object",
                  "properties" => {
                    "recursive" => { "$ref" => "#/components/schemas/Reference" }
                  }
                }
              }
            }
          }
        )

        factory = Openapi3Parser::NodeFactory::Schema::OasDialect3_1.new(factory_context)

        expect(described_class.call(factory)).to match(
          {
            "type" => "object",
            "properties" => {
              "recursive" => {
                "type" => "object",
                "properties" => {
                  "recursive" => an_instance_of(Openapi3Parser::NodeFactory::RecursiveResolvedInput)
                }
              }
            }
          }
        )
      end
    end
  end
end
