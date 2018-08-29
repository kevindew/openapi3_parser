# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Components < NodeFactory::Object
      allow_extensions
      field "schemas", factory: :schemas_factory
      field "responses", factory: :responses_factory
      field "parameters", factory: :parameters_factory
      field "examples", factory: :examples_factory
      field "requestBodies", factory: :request_bodies_factory
      field "headers", factory: :headers_factory
      field "securitySchemes", factory: :security_schemes_factory
      field "links", factory: :links_factory
      field "callbacks", factory: :callbacks_factory

      private

      def build_object(data, context)
        Node::Components.new(data, context)
      end

      def schemas_factory(context)
        referenceable_map_factory(context, NodeFactory::Schema)
      end

      def responses_factory(context)
        referenceable_map_factory(context, NodeFactory::Response)
      end

      def parameters_factory(context)
        referenceable_map_factory(context, NodeFactory::Parameter)
      end

      def examples_factory(context)
        referenceable_map_factory(context, NodeFactory::Example)
      end

      def request_bodies_factory(context)
        referenceable_map_factory(context, NodeFactory::RequestBody)
      end

      def headers_factory(context)
        referenceable_map_factory(context, NodeFactory::Header)
      end

      def security_schemes_factory(context)
        referenceable_map_factory(context, NodeFactory::SecurityScheme)
      end

      def links_factory(context)
        referenceable_map_factory(context, NodeFactory::Link)
      end

      def callbacks_factory(context)
        referenceable_map_factory(context, NodeFactory::Callback)
      end

      def referenceable_map_factory(context, factory)
        NodeFactory::Map.new(
          context,
          value_factory: NodeFactory::OptionalReference.new(factory),
          validate: Validation::InputValidator.new(Validators::ComponentKeys)
        )
      end

      def default
        {}
      end
    end
  end
end
