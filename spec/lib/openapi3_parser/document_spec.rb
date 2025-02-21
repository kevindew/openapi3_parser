# frozen_string_literal: true

RSpec.describe Openapi3Parser::Document do
  def raw_source_input(data)
    Openapi3Parser::SourceInput::Raw.new(data)
  end

  let(:source_data) do
    {
      "openapi" => "3.0.1",
      "info" => {
        "title" => "Minimal Openapi definition",
        "version" => "1.0.0"
      },
      "paths" => {},
      "components" => {}
    }
  end

  describe ".new" do
    context "when given a known OpenAPI version" do
      let(:instance) do
        described_class.new(
          raw_source_input(source_data.merge("openapi" => "3.0.1"))
        )
      end

      it "uses the minor version as the openapi_version" do
        expect(instance.openapi_version).to eq("3.0")
      end

      it "has no warnings" do
        expect(instance.warnings).to be_empty
      end
    end

    context "when no OpenAPI version is provided" do
      let(:input) { raw_source_input(source_data.merge("openapi" => nil)) }

      it "treats the version as the default for the library" do
        instance = nil
        expect { instance = described_class.new(input) }.to output.to_stderr
        expect(instance.openapi_version).to eq(Openapi3Parser::Document::DEFAULT_OPENAPI_VERSION)
      end

      it "has a warning" do
        instance = nil
        warning = /Unspecified OpenAPI version/
        expect { instance = described_class.new(input) }
          .to output(warning).to_stderr
        expect(instance.warnings).to include(warning)
      end

      it "doesn't output to stderr when emit_warnings is false" do
        expect { described_class.new(input, emit_warnings: false) }
          .not_to output.to_stderr
      end
    end

    context "when an unsupported OpenAPI version is provided" do
      let(:input) { raw_source_input(source_data.merge("openapi" => "2.0.0")) }

      it "treats the version as the default for the library" do
        instance = nil
        expect { instance = described_class.new(input) }.to output.to_stderr
        expect(instance.openapi_version).to eq(Openapi3Parser::Document::DEFAULT_OPENAPI_VERSION)
      end

      it "has a warning" do
        instance = nil
        warning = /Unsupported OpenAPI version #{Regexp.escape('(2.0.0)')}/
        expect { instance = described_class.new(input) }
          .to output(warning).to_stderr
        expect(instance.warnings).to include(warning)
      end

      it "doesn't output to stderr when emit_warnings is false" do
        expect { described_class.new(input, emit_warnings: false) }
          .not_to output.to_stderr
      end
    end
  end

  describe "#root" do
    it "returns the Openapi node" do
      expect(described_class.new(raw_source_input(source_data)).root)
        .to be_an_instance_of(Openapi3Parser::Node::Openapi)
    end
  end

  describe "#source_for_source_input" do
    it "returns a source object when given a known source input" do
      source_input = raw_source_input(source_data)
      instance = described_class.new(source_input)
      expect(instance.source_for_source_input(source_input))
        .to be_an_instance_of(Openapi3Parser::Source)
    end

    it "returns nil when given an unknown source input" do
      instance = described_class.new(raw_source_input(source_data))
      expect(instance.source_for_source_input(raw_source_input({})))
        .to be_nil
    end
  end

  describe "#reference_sources" do
    it "returns a source for any external references defined" do
      data = source_data.merge(
        "components" => {
          "responses" => {
            "a-response" => { "$ref" => "test.json" }
          }
        }
      )
      reference_sources = described_class.new(raw_source_input(data))
                                         .reference_sources

      expect(reference_sources)
        .to match_array(an_instance_of(Openapi3Parser::Source))
      expect(reference_sources.first.source_input)
        .to eq(Openapi3Parser::SourceInput::File.new("test.json"))
    end

    it "is empty when there are no external references" do
      data = source_data.merge("components" => {})
      reference_sources = described_class.new(raw_source_input(data))
                                         .reference_sources
      expect(reference_sources).to be_empty
    end
  end

  describe "#errors" do
    it "returns an instance of Validation::ErrorCollection" do
      instance = described_class.new(raw_source_input(source_data))
      expect(instance.errors)
        .to be_an_instance_of(Openapi3Parser::Validation::ErrorCollection)
    end

    it "is empty when there are no errors" do
      instance = described_class.new(raw_source_input(source_data))
      expect(instance.errors).to be_empty
    end

    it "returns errors for invalid source data" do
      instance = described_class.new(raw_source_input({ "openapi" => "3.0.0" }))
      expect(instance.errors).not_to be_empty
    end

    it "includes errors from referenced files" do
      data = source_data.merge(
        "components" => {
          "responses" => {
            "invalid-external-reference" => { "$ref" => "test.json#/invalid" }
          }
        }
      )
      allow(File).to receive(:read).and_return({ "invalid" => {} }.to_json)

      instance = described_class.new(raw_source_input(data))
      expect(instance.errors.to_h).to eq(
        "#/components/responses/invalid-external-reference/%24ref" =>
          ["test.json#/invalid does not resolve to a valid object"],
        "test.json#/invalid" =>
          ["Missing required fields: description"]
      )
    end
  end

  describe "#node_at" do
    let(:instance) { described_class.new(raw_source_input(source_data)) }

    it "can return a node when given a fragment string" do
      expect(instance.node_at("#/info"))
        .to be_an_instance_of(Openapi3Parser::Node::Info)
    end

    it "can return a node when given an array" do
      expect(instance.node_at(%w[info]))
        .to be_an_instance_of(Openapi3Parser::Node::Info)
    end

    it "can return a node when given a pointer object" do
      pointer = Openapi3Parser::Source::Pointer.new(%w[info])
      expect(instance.node_at(pointer))
        .to be_an_instance_of(Openapi3Parser::Node::Info)
    end

    it "returns nil when a node doesn't exist" do
      expect(instance.node_at("#/non-existent")).to be_nil
    end

    it "can return a node relative to a different node" do
      expect(instance.node_at("#../", "#/info/title"))
        .to be_an_instance_of(Openapi3Parser::Node::Info)
    end
  end

  describe "#resolved_input_at" do
    let(:instance) { described_class.new(raw_source_input(source_data)) }

    it "can look up a node's data when given a fragment string" do
      expect(instance.resolved_input_at("#/info/version"))
        .to eq("1.0.0")
    end

    it "can look up a node's data when given an array" do
      expect(instance.resolved_input_at(%w[info version]))
        .to eq("1.0.0")
    end

    it "can look up a node's data when given a pointer object" do
      pointer = Openapi3Parser::Source::Pointer.new(%w[info version])
      expect(instance.resolved_input_at(pointer))
        .to eq("1.0.0")
    end

    it "returns nil when a node doesn't exist" do
      expect(instance.resolved_input_at("#/non-existent")).to be_nil
    end

    it "can look up a node's data with a location relative to a different one" do
      expect(instance.resolved_input_at("#../version", "#/info/title"))
        .to eq("1.0.0")
    end
  end
end
