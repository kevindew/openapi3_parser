# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class MediaType < NodeFactory::Object
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
        factory = NodeFactory::Schema
        NodeFactory::OptionalReference.new(factory).call(context)
      end

      def examples_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Example)
        NodeFactory::Map.new(context,
                             default: nil,
                             value_factory: factory)
      end

      def encoding_factory(context)
        NodeFactory::Map.new(
          context,
          validate: EncodingValidator.new(self),
          value_factory: NodeFactory::Encoding
        )
      end

      class EncodingValidator
        def initialize(factory)
          @factory = factory
        end

        def call(validatable)
          missing_keys = validatable.input.keys - properties
          return if missing_keys.empty?

          validatable.add_error(error_message(missing_keys))
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
