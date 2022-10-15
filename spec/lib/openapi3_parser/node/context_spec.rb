# frozen_string_literal: true

RSpec.describe Openapi3Parser::Node::Context do
  describe ".root" do
    it "returns an instance of context with a root document_location" do
      factory_context = create_node_factory_context({})
      instance = described_class.root(factory_context)

      expect(instance).to be_a(described_class)
      expect(instance.document_location.to_s).to eq "#/"
    end

    it "sets an input location based on the factory source location" do
      factory_context = create_node_factory_context({})
      instance = described_class.root(factory_context)

      expect(instance.input_locations).to match_array(factory_context.source_location)
    end

    it "only sets an input location if it isn't a reference" do
      factory_context = create_node_factory_context({ "$ref" => "reference" })
      instance = described_class.root(factory_context)

      expect(instance.input_locations).to be_empty
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

    it "adds an input location if the data is not a reference" do
      parent_context = create_node_context({})
      factory_context = create_node_factory_context({})
      instance = described_class.next_field(parent_context, "key", factory_context)

      expect(instance.input_locations).to include(factory_context.source_location)
    end

    it "skips an input location if the data is just a reference" do
      parent_context = create_node_context({})
      factory_context = create_node_factory_context({ "$ref" => "reference" })
      instance = described_class.next_field(parent_context, "key", factory_context)

      expect(instance.input_locations).not_to include(factory_context.source_location)
    end
  end

  describe ".resolved_reference" do
    it "returns a context object with the referenced data merged without $ref" do
      current_context = create_node_context(
        { "$ref" => "#/reference", "first_name" => "John" },
        pointer_segments: %w[field]
      )

      reference_source_location = create_source_location({},
                                                         document: current_context.document,
                                                         pointer_segments: %w[reference])

      reference_factory_context = Openapi3Parser::NodeFactory::Context.new(
        { "first_name" => "Jake", "last_name" => "Smith" },
        source_location: reference_source_location,
        reference_locations: [reference_source_location]
      )

      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)
      expect(instance.input).to eq(
        { "first_name" => "John", "last_name" => "Smith" }
      )
    end

    it "doesn't merge data that is not an object" do
      current_context = create_node_context(
        { "$ref" => "#/reference", "another" => "field" },
        pointer_segments: %w[field]
      )

      reference_source_location = create_source_location({},
                                                         document: current_context.document,
                                                         pointer_segments: %w[reference])

      reference_factory_context = Openapi3Parser::NodeFactory::Context.new(
        "data",
        source_location: reference_source_location,
        reference_locations: [reference_source_location]
      )

      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)
      expect(instance.input).to eq("data")
    end

    it "maintains the document location of the current context" do
      current_context = create_node_context(
        { "$ref" => "#/reference" },
        pointer_segments: %w[field]
      )

      reference_source_location = create_source_location({},
                                                         document: current_context.document,
                                                         pointer_segments: %w[reference])

      reference_factory_context = Openapi3Parser::NodeFactory::Context.new(
        {},
        source_location: reference_source_location,
        reference_locations: [reference_source_location]
      )

      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance.document_location.to_s).to eq "#/field"
    end

    it "sets the source locations to all the reference locations" do
      current_context = create_node_context(
        { "$ref" => "#/reference" },
        pointer_segments: %w[field]
      )

      reference_source_location = create_source_location({},
                                                         document: current_context.document,
                                                         pointer_segments: %w[reference])

      reference_factory_context = Openapi3Parser::NodeFactory::Context.new(
        {},
        source_location: reference_source_location,
        reference_locations: [reference_source_location]
      )

      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance.source_locations).to eq(
        [current_context.source_locations.first, reference_source_location]
      )
    end

    it "sets the input locations to all the references that defined the data" do
      current_context = create_node_context(
        { "$ref" => "#/reference" },
        pointer_segments: %w[field]
      )

      reference_source_location = create_source_location({},
                                                         document: current_context.document,
                                                         pointer_segments: %w[reference])

      reference_factory_context = Openapi3Parser::NodeFactory::Context.new(
        {},
        source_location: reference_source_location,
        reference_locations: [reference_source_location]
      )

      instance = described_class.resolved_reference(current_context,
                                                    reference_factory_context)

      expect(instance.input_locations).to eq([reference_source_location])
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
                                     source_locations: [source_location],
                                     input_locations: [source_location])
      other = described_class.new({},
                                  document_location: document_location,
                                  source_locations: [source_location],
                                  input_locations: [source_location])

      expect(instance).to eq(other)
    end

    it "returns false when one of these differ" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_locations: [source_location],
                                     input_locations: [source_location])

      other_source_location = create_source_location(
        {},
        document: document_location.source.document,
        pointer_segments: %w[field_b]
      )

      other = described_class.new({},
                                  document_location: document_location,
                                  source_locations: [other_source_location],
                                  input_locations: [other_source_location])

      expect(instance).not_to eq(other)
    end
  end

  describe "#same_data_inputs?" do
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

    it "returns true when input and input locations match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_locations: [source_location],
                                     input_locations: [source_location])
      other = described_class.new({},
                                  document_location: other_document_location,
                                  source_locations: [source_location],
                                  input_locations: [source_location])

      expect(instance.same_data_inputs?(other)).to be true
    end

    it "returns false when input doesn't match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_locations: [source_location],
                                     input_locations: [source_location])
      other = described_class.new({ different: "data" },
                                  document_location: other_document_location,
                                  source_locations: [source_location],
                                  input_locations: [source_location])

      expect(instance.same_data_inputs?(other)).to be false
    end

    it "returns false when input locations don't match" do
      instance = described_class.new({},
                                     document_location: document_location,
                                     source_locations: [source_location],
                                     input_locations: [source_location])
      other = described_class.new({},
                                  document_location: other_document_location,
                                  source_locations: [source_location],
                                  input_locations: [])

      expect(instance.same_data_inputs?(other)).to be false
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

  describe "#openapi_version" do
    it "returns the document's OpenAPI version" do
      instance = create_node_context({}, document_input: { "openapi" => "3.1.0" })

      expect(instance.openapi_version).to eq("3.1")
    end
  end
end
