# frozen_string_literal: true

module Openapi3Parser
  module NodeFactory
    module ParameterLike
      def default_explode
        context.input["style"] == "form"
      end

      def schema_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Schema)
        factory.call(context)
      end

      def examples_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::Schema)
        NodeFactory::Map.new(context,
                             default: nil,
                             value_factory: factory)
      end

      def content_factory(context)
        NodeFactory::Map.new(context,
                             default: nil,
                             value_factory: NodeFactory::MediaType,
                             validate: method(:validate_content))
      end

      def validate_content(validatable)
        return if validatable.input.size == 1
        validatable.add_error("Must only have one item")
      end
    end
  end
end

# These are in the footer as a cyclic dependency can stop this module loading
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factory/map"
require "openapi3_parser/node_factory/schema"
require "openapi3_parser/node_factory/example"
require "openapi3_parser/node_factory/media_type"