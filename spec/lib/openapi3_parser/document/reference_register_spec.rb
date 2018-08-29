# frozen_string_literal: true

require "support/helpers/context"

RSpec.describe Openapi3Parser::Document::ReferenceRegister do
  include Helpers::Context

  let(:instance) { described_class.new }

  describe "#register" do
    context "when something is registered" do
      let(:context) { create_context({}) }
      let(:source) { context.source }
      let(:factory) { Openapi3Parser::NodeFactory::Openapi.new(context) }

      it "registers the source" do
        instance.register(factory)
        expect(instance.sources).to match_array([source])
      end

      it "registers the factory" do
        instance.register(factory)
        expect(instance.factories).to match_array([factory])
      end
    end

    context "when a source is already registered" do
      let(:root_context) { create_context({}) }
      let(:source) { root_context.source }
      let(:root_factory) do
        Openapi3Parser::NodeFactory::Openapi.new(root_context)
      end
      let(:next_context) do
        Openapi3Parser::Context.next_field(root_context, "path")
      end
      let(:next_factory) do
        Openapi3Parser::NodeFactory::Openapi.new(next_context)
      end

      before do
        instance.register(root_factory)
      end

      it "registers the source once" do
        instance.register(next_factory)
        expect(instance.sources).to match_array([source])
      end

      it "registers both factories" do
        instance.register(next_factory)
        expect(instance.factories).to match_array([root_factory, next_factory])
      end
    end

    context "when a factory is already registered" do
      let(:root_context) { create_context({}) }
      let(:source) { root_context.source }
      let(:root_factory) do
        Openapi3Parser::NodeFactory::Openapi.new(root_context)
      end
      let(:next_factory) do
        Openapi3Parser::NodeFactory::Openapi.new(root_context)
      end

      before do
        instance.register(root_factory)
      end

      it "registers the source once" do
        instance.register(next_factory)
        expect(instance.sources).to match_array([source])
      end

      it "registers the factory once" do
        instance.register(next_factory)
        expect(instance.factories).to match_array([root_factory])
      end
    end

    context "when it is frozen" do
      let(:context) { create_context({}) }
      let(:factory) { Openapi3Parser::NodeFactory::Openapi.new(context) }

      before { instance.freeze }

      it "raises an error" do
        immutable_error = Openapi3Parser::Error::ImmutableObject
        expect { instance.register(factory) }.to raise_error(immutable_error)
      end
    end
  end

  describe "#freeze" do
    before { instance.freeze }

    it "freezes the object" do
      expect(instance).to be_frozen
    end

    it "freezes sources" do
      expect(instance.sources).to be_frozen
    end

    it "freezes factories" do
      expect(instance.factories).to be_frozen
    end
  end
end
