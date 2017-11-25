# frozen_string_literal: true

require "openapi_parser/nodes/operation"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/array"
require "openapi_parser/node_factories/external_documentation"
require "openapi_parser/node_factories/parameter"
require "openapi_parser/node_factories/request_body"
require "openapi_parser/node_factories/server"
require "openapi_parser/node_factories/security_requirement"

module OpenapiParser
  module NodeFactories
    class Operation
      include NodeFactory::Object

      allow_extensions
      field "tags", factory: :tags_factory
      field "summary", input_type: String
      field "description", input_type: String
      field "externalDocs", factory: NodeFactories::ExternalDocumentation
      field "operationId", input_type: String
      field "parameters", factory: :parameters_factory
      field "requestBody", factory: :request_body_factory
      # @TODO responses
      # @TODO callbacks
      field "deprecated", input_type: :boolean, default: false
      field "security", factory: :security_factory
      field "servers", factory: :servers_factory

      private

      def build_object(data, context)
        Nodes::Operation.new(data, context)
      end

      def tags_factory(context)
        NodeFactories::Array.new(context, value_input_type: String)
      end

      def parameters_factory(context)
        factory = NodeFactory::OptionalReference.new(NodeFactories::Parameter)
        NodeFactories::Array.new(context, value_factory: factory)
      end

      def request_body_factory(context)
        factory = NodeFactories::RequestBody
        NodeFactory::OptionalReference.new(factory).call(context)
      end

      def security_factory(context)
        NodeFactories::Array.new(
          context, value_factory: NodeFactories::SecurityRequirement
        )
      end

      def servers_factory(context)
        NodeFactories::Array.new(context, value_factory: NodeFactories::Server)
      end
    end
  end
end
