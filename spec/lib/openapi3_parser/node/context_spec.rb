# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Context do
  describe ".root" do
    it "returns an instance of context with a root document_location" do
      factory_context = create_node_factory_context({})
      instance = described_class.root(factory_context)

      expect(instance).to be_a(described_class)
      expect(instance.document_location.to_s).to eq "#/"
    end
  end

  describe ".next_field" do
    it "returns an instance of context with the field's document_location" do
      parent_context = create_node_context({})
      factory_context = create_node_factory_context({})
      instance = described_class.next_field(parent_context, "key", factory_context)

      expect(instance).to be_a(described_class)
      expect(instance.document_location.to_s).to eq "#/key"
    end
  end

  describe ".resolved_reference" do
    let(:current_context) do
      create_node_context({}, pointer_segments: %w[field])
    end

    let(:reference_factory_context) do
      source_location = create_source_location(
        {},
        document: current_context.document,
        pointer_segments: %w[data]
      )

      reference_location = create_source_location(
        {},
        document: current_context.document,
        pointer_segments: %w[field $ref]
      )

      Openapi3Parser::NodeFactory::Context.new(
        "data",
        source_location: source_location,
        reference_locations: [reference_location]
      )
    end

    it "returns a context object with the referenced data" do
      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance).to be_a(described_class)
      expect(instance.input).to eq "data"
    end

    it "maintains the document location of the current context" do
      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance.document_location.to_s).to eq "#/field"
    end

    it "sets the source location to the location of the referenced data" do
      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance.source_location.to_s).to eq "#/data"
    end
  end

  describe "#==" do
    let(:document_location) do
      create_source_location({}, pointer_segments: %w[field_a])
    end

    let(:source_location) do
      create_source_location({},
                             document: document_location.source.document,
                             pointer_segments: %w[ref_a])
    end

    it "returns true when input and locations match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_location: source_location)
      other = described_class.new({},
                                  document_location: document_location,
                                  source_location: source_location)

      expect(instance).to eq(other)
    end

    it "returns false when one of these differ" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_location: source_location)

      other_source_location = create_source_location(
        {},
        document: document_location.source.document,
        pointer_segments: %w[field_b]
      )

      other = described_class.new({},
                                  document_location: document_location,
                                  source_location: other_source_location)

      expect(instance).not_to eq(other)
    end
  end

  describe "#same_data_and_source?" do
    let(:source_location) do
      create_source_location({}, pointer_segments: %w[ref_a])
    end

    let(:document_location) do
      create_source_location({},
                             document: source_location.source.document,
                             pointer_segments: %w[field_a])
    end

    let(:other_document_location) do
      create_source_location({},
                             document: source_location.source.document,
                             pointer_segments: %w[field_b])
    end

    it "returns true when input and source location match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_location: source_location)
      other = described_class.new({},
                                  document_location: other_document_location,
                                  source_location: source_location)

      expect(instance.same_data_and_source?(other)).to be true
    end

    it "returns false when input and source location doesn't match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_location: source_location)
      other = described_class.new({ different: "data" },
                                  document_location: other_document_location,
                                  source_location: source_location)

      expect(instance.same_data_and_source?(other)).to be false
    end
  end

  describe "#relative_node" do
    let(:instance) do
      info = { "title" => "Minimal Openapi definition", "version" => "1.0.0" }
      create_node_context(info,
                          document_input: { "openapi" => "3.0.0",
                                            "info" => info,
                                            "paths" => {} },
                          pointer_segments: %w[info])
    end

    it "returns the data at a node if the pointer exists" do
      expect(instance.relative_node("#version")).to eq "1.0.0"
    end

    it "returns nil when the pointer doesn't exist" do
      expect(instance.relative_node("#non-existent")).to be_nil
    end
  end

  describe "#parent_node" do
    it "returns the parent node when there is one" do
      info = { "title" => "Minimal Openapi definition", "version" => "1.0.0" }
      instance = create_node_context(
        info,
        document_input: {
          "openapi" => "3.0.0",
          "info" => info,
          "paths" => {}
        },
        pointer_segments: ["info"]
      )

      expect(instance.parent_node)
        .to be_an_instance_of(Openapi3Parser::Node::Openapi)
    end

    it "returns nil when there isn't a parent (for example at root)" do
      instance = create_node_context({}, document_input: {})
      expect(instance.parent_node).to be_nil
    end
  end
end
