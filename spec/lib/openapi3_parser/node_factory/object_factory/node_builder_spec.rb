# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::ObjectFactory::NodeBuilder do
  describe "#node_data" do
    context "when factory input is nil" do
      let(:factory_context) { create_node_factory_context(nil) }

      it "returns nil for a node with no data fields" do
        node_builder = described_class.new(
          Openapi3Parser::NodeFactory::Object.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data).to be_nil
      end

      it "returns nil for a factory with fields and a nil default" do
        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name"

          def default
            nil
          end
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data).to be_nil
      end

      it "an object with field defaults for a factory with fields" do
        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name"

          def default
            {}
          end
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data).to eq({ "name" => nil })
      end
    end

    context "when there is factory input" do
      it "raises an error if the data isn't the expected type" do
        factory_context = create_node_factory_context("not a hash")

        node_builder = described_class.new(
          Openapi3Parser::NodeFactory::Object.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect { node_builder.node_data }.to raise_error(Openapi3Parser::Error::InvalidType)
      end

      it "raises an error if the the data isn't valid" do
        factory_context = create_node_factory_context({})

        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name", required: true
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect { node_builder.node_data }.to raise_error(Openapi3Parser::Error::MissingFields)
      end

      it "returns an object of the node's data" do
        factory_context = create_node_factory_context({ "name" => "Steve" })

        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name"
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data).to eq({ "name" => "Steve" })
      end

      it "populates any missing fields with their default" do
        factory_context = create_node_factory_context({})

        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "name", default: "Joe Bloggs"
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data).to eq({ "name" => "Joe Bloggs" })
      end

      it "assigns Node::Placeholder objects for any fields that are nodes" do
        factory_context = create_node_factory_context(
          { "contact" => { "name" => "Joe Bloggs" } }
        )

        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          field "contact", factory: Openapi3Parser::NodeFactory::Contact
        end

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data)
          .to match({ "contact" => an_instance_of(Openapi3Parser::Node::Placeholder) })
      end
    end

    context "when the factory includes a reference to other nodes" do
      let(:document_input) do
        {
          "components" => {
            "schemas" => {
              "Referenced" => {
                "first_name" => "Joe",
                "last_name" => "Bloggs"
              }
            }
          }
        }
      end

      let(:factory) do
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

      it "returns the data merging together reference values" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Referenced",
            "last_name" => "Smith" },
          document_input: document_input
        )

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data)
          .to match({ "first_name" => "Joe", "last_name" => "Smith" })
      end

      it "allows a nil input to replace a referenced field" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Referenced",
            "last_name" => nil },
          document_input: document_input
        )

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data)
          .to match({ "first_name" => "Joe", "last_name" => nil })
      end

      it "returns the data without any $ref fields" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Referenced" },
          document_input: document_input
        )

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect(node_builder.node_data.keys).not_to include("$ref")
      end

      it "raises an error if a reference is broken" do
        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Broken" },
          document_input: document_input
        )

        node_builder = described_class.new(
          factory.new(factory_context),
          node_factory_context_to_node_context(factory_context)
        )

        expect { node_builder.node_data }
          .to raise_error(Openapi3Parser::Error::InvalidData)
      end
    end
  end

  describe "#node_context" do
    context "when the factory doesn't have references" do
      it "returns the given node context" do
        factory_context = create_node_factory_context(nil)
        node_context = node_factory_context_to_node_context(factory_context)
        node_builder = described_class.new(
          Openapi3Parser::NodeFactory::Object.new(factory_context),
          node_context
        )

        expect(node_builder.node_context).to be(node_context)
      end
    end

    context "when the factory has references" do
      it "returns a node context appropriate for the references" do
        factory = Class.new(Openapi3Parser::NodeFactory::Object) do
          include Openapi3Parser::NodeFactory::Referenceable

          field "$ref", factory: :ref_factory
          field "name"

          def ref_factory(context)
            Openapi3Parser::NodeFactory::Fields::Reference.new(context, self.class)
          end
        end

        factory_context = create_node_factory_context(
          { "$ref" => "#/components/schemas/Reference" },
          document_input: {
            "components" => {
              "schemas" => {
                "Reference" => {
                  "name" => "Joe"
                }
              }
            }
          }
        )

        node_context = node_factory_context_to_node_context(factory_context)
        node_builder = described_class.new(factory.new(factory_context), node_context)

        expect(node_builder.node_context.source_locations.map(&:to_s))
          .to eq(["#/", "#/components/schemas/Reference"])
      end
    end
  end

  describe "#factory_to_build" do
    it "returns the given factory for a factory without references" do
      factory_context = create_node_factory_context(nil)
      factory = Openapi3Parser::NodeFactory::Object.new(factory_context)
      node_builder = described_class.new(factory, node_factory_context_to_node_context(factory_context))

      expect(node_builder.factory_to_build).to be(factory)
    end

    it "returns the last referenced factory for a factory with references" do
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        field "name"
      end

      factory_context = create_node_factory_context(
        { "$ref" => "#/Referenced" },
        document_input: {
          "Referenced" => {
            "name" => "Joe"
          }
        }
      )

      factory = Openapi3Parser::NodeFactory::OptionalReference.new(factory_class).call(factory_context)
      node_builder = described_class.new(factory, node_factory_context_to_node_context(factory_context))

      expect(node_builder.factory_to_build).to be_an_instance_of(factory_class)
    end
  end

  describe "#build_node" do
    it "returns nil if no node_data was determined" do
      factory_context = create_node_factory_context(nil)
      factory = Openapi3Parser::NodeFactory::Object.new(factory_context)
      node_builder = described_class.new(factory, node_factory_context_to_node_context(factory_context))

      expect(node_builder.build_node).to be_nil
    end

    it "returns a created node for the last referenced factory if there is build data" do
      factory_context = create_node_factory_context({})
      factory_class = Class.new(Openapi3Parser::NodeFactory::Object) do
        def build_node(data, node_context)
          Openapi3Parser::Node::Object.new(data, node_context)
        end
      end

      node_builder = described_class.new(factory_class.new(factory_context),
                                         node_factory_context_to_node_context(factory_context))

      expect(node_builder.build_node).to be_an_instance_of(Openapi3Parser::Node::Object)
    end
  end
end
