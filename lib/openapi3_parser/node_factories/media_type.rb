# frozen_string_literal: true

require "openapi3_parser/node/media_type"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/node_factories/schema"
require "openapi3_parser/node_factories/example"
require "openapi3_parser/node_factories/encoding"

module Openapi3Parser
  module NodeFactories
    class MediaType
      include NodeFactory::Object

      allow_extensions

      field "schema", factory: :schema_factory
      field "example"
      field "examples", factory: :examples_factory
      field "encoding", factory: :encoding_factory

      mutually_exclusive "example", "examples"

      private

      def build_object(data, context)
        Node::MediaType.new(data, context)
      end

      def schema_factory(context)
        factory = NodeFactories::Schema
        NodeFactory::OptionalReference.new(factory).call(context)
      end

      def examples_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Example)
        NodeFactories::Map.new(context, default: nil, value_factory: factory)
      end

      def encoding_factory(context)
        NodeFactories::Map.new(
          context,
          validate: EncodingValidator.new(self),
          value_factory: NodeFactories::Encoding
        )
      end

      class EncodingValidator
        def initialize(factory)
          @factory = factory
        end

        def call(input, _context)
          missing_keys = input.keys - properties
          error_message(missing_keys) unless missing_keys.empty?
        end

        private

        attr_reader :factory

        def properties
          properties = factory.resolved_input.dig("schema", "properties")
          properties.respond_to?(:keys) ? properties.keys : []
        end

        def error_message(missing_keys)
          keys = missing_keys.join(", ")
          "Keys are not defined as schema properties: #{keys}"
        end
      end
    end
  end
end
