# frozen_string_literal: true

require "openapi_parser/nodes/components"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/map"
require "openapi_parser/node_factories/schema"
require "openapi_parser/node_factories/response"
require "openapi_parser/node_factories/parameter"
require "openapi_parser/node_factories/example"
require "openapi_parser/node_factories/request_body"
require "openapi_parser/node_factories/header"
require "openapi_parser/node_factories/security_scheme"
require "openapi_parser/node_factories/link"

module OpenapiParser
  module NodeFactories
    class Components
      include NodeFactory::Object

      allow_extensions
      field "schemas", factory: :schemas_factory
      field "responses", factory: :responses_factory
      field "parameters", factory: :parameters_factory
      field "examples", factory: :examples_factory
      field "requestBodies", factory: :request_bodies_factory
      field "headers", factory: :headers_factory
      field "securitySchemes", factory: :security_schemes_factory
      field "links", factory: :links_factory
      # @TODO callbakcs

      private

      def build_object(data, context)
        Nodes::Components.new(data, context)
      end

      def schemas_factory(context)
        referenceable_map_factory(context, NodeFactories::Schema)
      end

      def responses_factory(context)
        referenceable_map_factory(context, NodeFactories::Response)
      end

      def parameters_factory(context)
        referenceable_map_factory(context, NodeFactories::Parameter)
      end

      def examples_factory(context)
        referenceable_map_factory(context, NodeFactories::Example)
      end

      def request_bodies_factory(context)
        referenceable_map_factory(context, NodeFactories::RequestBody)
      end

      def headers_factory(context)
        referenceable_map_factory(context, NodeFactories::Header)
      end

      def security_schemes_factory(context)
        referenceable_map_factory(context, NodeFactories::SecurityScheme)
      end

      def links_factory(context)
        referenceable_map_factory(context, NodeFactories::Link)
      end

      def referenceable_map_factory(context, factory)
        NodeFactories::Map.new(
          context,
          value_factory: NodeFactory::OptionalReference.new(factory)
        )
      end
    end
  end
end
