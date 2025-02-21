# frozen_string_literal: true

RSpec.describe Openapi3Parser::NodeFactory::Schema::V3_1 do
  # TODO: perhaps a behaves like referenceable node object factory?

  # Basic c+p of V3_0 Schema test for now
  it_behaves_like "node object factory", Openapi3Parser::Node::Schema::V3_1 do
    let(:input) do
      {
        "allOf" => [
          { "$ref" => "#/components/schemas/Pet" },
          {
            "type" => "object",
            "properties" => {
              "bark" => { "type" => "string" }
            }
          }
        ]
      }
    end

    let(:document_input) do
      {
        "openapi" => "3.1.0",
        "components" => {
          "schemas" => {
            "Pet" => {
              "type" => "object",
              "required" => %w[pet_type],
              "properties" => {
                "pet_type" => { "type" => "string" }
              },
              "discriminator" => {
                "propertyName" => "pet_type",
                "mapping" => { "cachorro" => "Dog" }
              }
            }
          }
        }
      }
    end

    let(:node_factory_context) do
      create_node_factory_context(input, document_input:)
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "schema factory"

  describe "type validation" do
    it "rejects a non object or boolean input with an appropriate explanation" do
      instance = described_class.new(create_node_factory_context(15))

      expect(instance).to have_validation_error("#/").with_message("Invalid type. Expected Object or Boolean")
    end

    it "raises the appropriate error when a non object or boolean input is built" do
      node_factory_context = create_node_factory_context("blah")
      instance = described_class.new(node_factory_context)
      node_context = node_factory_context_to_node_context(node_factory_context)

      expect { instance.node(node_context) }
        .to raise_error(Openapi3Parser::Error::InvalidType,
                        "Invalid type for #/: Expected Object or Boolean")
    end
  end

  describe "boolean input" do
    it "is valid for a boolean input" do
      instance = described_class.new(create_node_factory_context(false))

      expect(instance).to be_valid
      expect(instance.boolean_input?).to be(true)
    end

    it "can build a Schema::V3_1 node with a boolean input" do
      node_factory_context = create_node_factory_context(true)
      instance = described_class.new(node_factory_context)
      node_context = node_factory_context_to_node_context(node_factory_context)
      node = instance.node(node_context)

      expect(node).to be_an_instance_of(Openapi3Parser::Node::Schema::V3_1)
    end

    it "sets the data attribute to a boolean when that is input" do
      node_factory_context = create_node_factory_context(true)
      instance = described_class.new(node_factory_context)

      expect(instance.data).to be(true)
    end

    it "sets the data attribute to nil when given a type other than boolean or object" do
      node_factory_context = create_node_factory_context(25)
      instance = described_class.new(node_factory_context)

      expect(instance.data).to be_nil
    end

    context "when a referenced schema is a boolean" do
      let(:document_input) do
        {
          "openapi" => "3.1.0",
          "components" => {
            "schemas" => {
              "Bool" => true
            }
          }
        }
      end

      it "is valid" do
        input = { "$ref" => "#/components/schemas/Bool" }
        instance = described_class.new(create_node_factory_context(input, document_input:))

        expect(instance).to be_valid
        expect(instance.boolean_input?).to be(true)
      end

      it "doesn't merge any fields" do
        input = {
          "description" => "A description that will be ignored",
          "$ref" => "#/components/schemas/Bool"
        }

        instance = described_class.new(create_node_factory_context(input, document_input:))

        expect(instance.resolved_input).to be(true)
      end
    end
  end

  describe "validating JSON schema dialect" do
    let(:global_json_schema_dialect) { nil }
    let(:document_input) do
      {
        "openapi" => "3.1.0",
        "jsonSchemaDialect" => global_json_schema_dialect
      }
    end
    let(:document) do
      source_input = Openapi3Parser::SourceInput::Raw.new(document_input)
      Openapi3Parser::Document.new(source_input)
    end

    before { allow(document).to receive(:unsupported_schema_dialect) }

    context "when the $schema value is the OAS base one" do
      it "doesn't flag the schema as an unsupported dialect" do
        node_factory_context = create_node_factory_context(
          { "$schema" => described_class::OAS_DIALECT },
          document:
        )

        instance = described_class.new(node_factory_context)
        instance.valid?

        expect(document).not_to have_received(:unsupported_schema_dialect)
      end
    end

    context "when the $schema value is not the OAS base one" do
      it "flags the schema as an unsupported dialect" do
        node_factory_context = create_node_factory_context(
          { "$schema" => "https://example.com/schema" },
          document:
        )

        instance = described_class.new(node_factory_context)
        instance.valid?

        expect(document)
          .to have_received(:unsupported_schema_dialect)
          .with("https://example.com/schema")
      end

      it "has a validation error if the schema dialect is not a valid URI" do
        node_factory_context = create_node_factory_context(
          { "$schema" => "not a URI" },
          document:
        )

        instance = described_class.new(node_factory_context)

        expect(instance)
          .to have_validation_error("#/%24schema")
          .with_message('"not a URI" is not a valid URI')
      end
    end

    context "when the $schema value is a non string" do
      it "runs to_s to report it as an unsupported_schema_dialect" do
        node_factory_context = create_node_factory_context(
          { "$schema" => [] },
          document:
        )

        instance = described_class.new(node_factory_context)
        instance.valid?

        expect(document)
          .to have_received(:unsupported_schema_dialect)
          .with("[]")
      end

      it "has a validation error" do
        node_factory_context = create_node_factory_context(
          { "$schema" => [] },
          document:
        )

        instance = described_class.new(node_factory_context)

        expect(instance)
          .to have_validation_error("#/%24schema")
          .with_message("Invalid type. Expected String")
      end
    end

    context "when the $schema value is empty and the document has the OAS base one" do
      let(:global_json_schema_dialect) { described_class::OAS_DIALECT }

      it "doesn't flag the schema as an unsupported dialect" do
        node_factory_context = create_node_factory_context({}, document:)

        instance = described_class.new(node_factory_context)
        instance.valid?

        expect(document).not_to have_received(:unsupported_schema_dialect)
      end
    end

    context "when the $schema value is empty and the document has a none OAS base one" do
      let(:global_json_schema_dialect) { "https://example.com/schema" }

      it "doesn't flag the schema as an unsupported dialect" do
        node_factory_context = create_node_factory_context({}, document:)

        instance = described_class.new(node_factory_context)
        instance.valid?

        expect(document)
          .to have_received(:unsupported_schema_dialect)
          .with(global_json_schema_dialect)
      end
    end
  end

  describe "type field" do
    it "is valid for a string input of the 7 allowed types" do
      described_class::JSON_SCHEMA_ALLOWED_TYPES.each do |type|
        instance = described_class.new(
          create_node_factory_context({ "type" => type })
        )

        expect(instance).to be_valid
      end
    end

    it "is valid for an array of unique string items" do
      instance = described_class.new(
        create_node_factory_context({
                                      "type" => described_class::JSON_SCHEMA_ALLOWED_TYPES
                                    })
      )

      expect(instance).to be_valid
    end

    it "defaults to a value of nil" do
      instance = described_class.new(create_node_factory_context({}))

      expect(instance.data["type"]).to be_nil
      expect(instance).to be_valid
    end

    it "is invalid for an input type other than string or array" do
      instance = described_class.new(
        create_node_factory_context({ "type" => { "object" => "hi" } })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("type must be a string or an array")
    end

    it "is invalid for a string outside the 7 allowed types" do
      instance = described_class.new(
        create_node_factory_context({ "type" => "oogabooga" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("type (oogabooga) must be one of null, boolean, object, array, number, string and integer")
    end

    it "is invalid for an array with inputs other than strings" do
      instance = described_class.new(
        create_node_factory_context({ "type" => [12, 0.5] })
      )

      message = "type contains unexpected items (12 and 0.5) outside of " \
                "null, boolean, object, array, number, string and integer"
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message(message)
    end

    it "is invalid for an array with repeated items" do
      allowed_type = described_class::JSON_SCHEMA_ALLOWED_TYPES.first
      factory_context = create_node_factory_context({ "type" => [allowed_type, allowed_type] })

      instance = described_class.new(factory_context)

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/type")
        .with_message("Duplicate entries in type array")
    end
  end

  describe "examples field" do
    it "is valid with an array with any type values" do
      instance = described_class.new(
        create_node_factory_context({ "examples" => [%w[a b], "test", nil] })
      )

      expect(instance).to be_valid
    end

    it "is invalid for a type other than array" do
      instance = described_class.new(
        create_node_factory_context({ "examples" => "string" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/examples")
        .with_message("Invalid type. Expected Array")
    end
  end

  describe "contentMediaType field" do
    it "is valid with a media type string" do
      instance = described_class.new(
        create_node_factory_context({ "contentMediaType" => "image/png" })
      )

      expect(instance).to be_valid
    end

    it "is invalid with a non media type string" do
      instance = described_class.new(
        create_node_factory_context({ "contentMediaType" => "not a media type" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/contentMediaType")
        .with_message('"not a media type" is not a valid media type')
    end
  end

  describe "prefixItems field" do
    it "is valid with an array with schema values" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => [{ "type" => "string" }] })
      )

      expect(instance).to be_valid
    end

    it "is invalid for a type other than array" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => "string" })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/prefixItems")
        .with_message("Invalid type. Expected Array")
    end

    it "is invalid for values other than objects" do
      instance = described_class.new(
        create_node_factory_context({ "prefixItems" => %w[string] })
      )

      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/prefixItems/0")
        .with_message("Invalid type. Expected Object")
    end
  end
end
