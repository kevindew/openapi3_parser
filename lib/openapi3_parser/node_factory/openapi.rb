# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/info"
require "openapi3_parser/node_factory/paths"
require "openapi3_parser/node_factory/components"
require "openapi3_parser/node_factory/external_documentation"

module Openapi3Parser
  module NodeFactory
    class Openapi < NodeFactory::Object
      allow_extensions

      field "openapi", input_type: String, required: true
      field "info", factory: NodeFactory::Info, required: true
      field "servers", factory: :servers_factory
      field "paths",
            factory: NodeFactory::Paths,
            required: ->(context) { context.openapi_version < "3.1" }
      field "webhooks",
            factory: :webhooks_factory,
            allowed: ->(context) { context.openapi_version >= "3.1" }
      field "components", factory: NodeFactory::Components
      field "security", factory: :security_factory
      field "tags", factory: :tags_factory
      field "externalDocs", factory: NodeFactory::ExternalDocumentation

      validate do |validatable|
        next if validatable.context.openapi_version < "3.1"
        next if (validatable.input.keys & %w[components paths webhooks]).any?

        validatable.add_error("At least one of components, paths and webhooks fields are required")
      end

      def can_use_default?
        false
      end

      def build_node(data, node_context)
        Node::Openapi.new(data, node_context)
      end

      private

      def servers_factory(context)
        NodeFactory::Array.new(context,
                               default: [{ "url" => "/" }],
                               use_default_on_empty: true,
                               value_factory: NodeFactory::Server)
      end

      def webhooks_factory(context)
        NodeFactory::Map.new(
          context,
          value_factory: NodeFactory::OptionalReference.new(NodeFactory::PathItem)
        )
      end

      def security_factory(context)
        NodeFactory::Array.new(context,
                               value_factory: NodeFactory::SecurityRequirement)
      end

      def tags_factory(context)
        validate_unique_tags = lambda do |validatable|
          names = validatable.factory.context.input.map { |i| i["name"] }
          return if names.uniq.count == names.count

          dupes = names.find_all { |name| names.count(name) > 1 }
          validatable.add_error(
            "Duplicate tag names: #{dupes.uniq.join(', ')}"
          )
        end

        NodeFactory::Array.new(context,
                               value_factory: NodeFactory::Tag,
                               validate: validate_unique_tags)
      end
    end
  end
end
