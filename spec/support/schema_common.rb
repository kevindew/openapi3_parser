# frozen_string_literal: true

# This file contains shared examples that can be used on the schema node_factory
# and schema node classes for common functionality.

RSpec.shared_examples "schema factory" do
  it_behaves_like "default field", field: "nullable", defaults_to: false do
    let(:node_factory_context) do
      create_node_factory_context({ "nullable" => nullable })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "readOnly",
                  defaults_to: false,
                  var_name: :read_only do
    let(:node_factory_context) do
      create_node_factory_context({ "readOnly" => read_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "writeOnly",
                  defaults_to: false,
                  var_name: :write_only do
    let(:node_factory_context) do
      create_node_factory_context({ "writeOnly" => write_only })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  it_behaves_like "default field",
                  field: "deprecated",
                  defaults_to: false,
                  var_name: :deprecated do
    let(:node_factory_context) do
      create_node_factory_context({ "deprecated" => deprecated })
    end

    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "default field" do
    it "supports a default field of false" do
      node_factory_context = create_node_factory_context({ "default" => false })
      node_context = node_factory_context_to_node_context(node_factory_context)

      instance = described_class.new(node_factory_context)

      expect(instance).to be_valid
      expect(instance.node(node_context).default).to be(false)
    end
  end

  describe "validating writeOnly and readOnly" do
    it "is invalid when both writeOnly and readOnly are true" do
      instance = described_class.new(
        create_node_factory_context({ "writeOnly" => true, "readOnly" => true })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/")
        .with_message("readOnly and writeOnly cannot both be true")
    end

    it "is valid when one of writeOnly and readOnly are true" do
      write_only = described_class.new(
        create_node_factory_context({ "writeOnly" => true })
      )
      expect(write_only).to be_valid

      read_only = described_class.new(
        create_node_factory_context({ "readOnly" => true })
      )
      expect(read_only).to be_valid
    end
  end

  describe "validating additionalProperties" do
    it "is valid for a boolean" do
      true_instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => true })
      )
      expect(true_instance).to be_valid

      false_instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => false })
      )
      expect(false_instance).to be_valid
    end

    it "is valid for a schema" do
      instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => { "type" => "object" } })
      )
      expect(instance).to be_valid
    end

    it "is invalid for something different" do
      instance = described_class.new(
        create_node_factory_context({ "additionalProperties" => %w[item1 item2] })
      )
      expect(instance).not_to be_valid
      expect(instance)
        .to have_validation_error("#/additionalProperties")
        .with_message("Expected a Boolean or an Object")
    end
  end
end

RSpec.shared_examples "schema node" do |openapi_version:|
  describe "#name" do
    it "returns the key of the context when the item is defined within components/schemas" do
      node_context = create_node_context(
        {},
        pointer_segments: %w[components schemas Pet]
      )
      instance = described_class.new({}, node_context)
      expect(instance.name).to eq "Pet"
    end

    it "returns nil when a schema is defined outside of components/schemas" do
      node_context = create_node_context(
        {},
        pointer_segments: %w[content application/json schema]
      )
      instance = described_class.new({}, node_context)
      expect(instance.name).to be_nil
    end
  end

  describe "#requires?" do
    let(:node) do
      input = {
        "type" => "object",
        "required" => %w[field_a],
        "properties" => {
          "field_a" => { "type" => "string" },
          "field_b" => { "type" => "string" }
        }
      }

      document_input = {
        "openapi" => openapi_version
      }

      factory_context = create_node_factory_context(input, document_input:)
      Openapi3Parser::NodeFactory::Schema
        .build_factory(factory_context)
        .node(node_factory_context_to_node_context(factory_context))
    end

    context "when enquiring with a field name" do
      it "returns true when a field name is required" do
        expect(node.requires?("field_a")).to be true
      end

      it "returns false when a field name is not required" do
        expect(node.requires?("field_b")).to be false
      end
    end

    context "when enquiring with a schema object" do
      it "returns true when the schema is required" do
        expect(node.requires?(node.properties["field_a"])).to be true
      end

      it "returns false when the schema is not required" do
        expect(node.requires?(node.properties["field_b"])).to be false
      end
    end

    context "when comparing referenced schemas" do
      let(:node) do
        input = {
          "type" => "object",
          "required" => %w[field_a],
          "properties" => {
            "field_a" => { "$ref" => "#/referenced_item" },
            "field_b" => { "$ref" => "#/referenced_item" }
          }
        }

        document_input = {
          "openapi" => openapi_version,
          "referenced_item" => { "type" => "string" }
        }

        factory_context = create_node_factory_context(input, document_input:)
        Openapi3Parser::NodeFactory::Schema
          .build_factory(factory_context)
          .node(node_factory_context_to_node_context(factory_context))
      end

      it "returns true for the required reference field" do
        expect(node.requires?(node.properties["field_a"])).to be true
      end

      it "returns false for the reference field that isn't required" do
        expect(node.requires?(node.properties["field_b"])).to be false
      end
    end
  end
end
