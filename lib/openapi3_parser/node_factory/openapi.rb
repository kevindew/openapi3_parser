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
      field "paths", factory: NodeFactory::Paths, required: true
      field "components", factory: NodeFactory::Components
      field "security", factory: :security_factory
      field "tags", factory: :tags_factory
      field "externalDocs", factory: NodeFactory::ExternalDocumentation

      def can_use_default?
        false
      end

      private

      def build_object(data, context)
        Node::Openapi.new(data, context)
      end

      def servers_factory(context)
        NodeFactory::Array.new(context,
                               default: [{ "url" => "/" }],
                               use_default_on_empty: true,
                               value_factory: NodeFactory::Server)
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
