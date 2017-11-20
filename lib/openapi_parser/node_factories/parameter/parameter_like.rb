# frozen_string_literal: true

require "openapi_parser/node_factory/optional_reference"
require "openapi_parser/node_factories/schema"
require "openapi_parser/node_factories/map"
require "openapi_parser/node_factories/example"
require "openapi_parser/node_factories/media_type"

module OpenapiParser
  module NodeFactories
    class Parameter
      module ParameterLike
        def default_explode
          context.input["style"] == "form"
        end

        def schema_factory(context)
          factory = NodeFactory::OptionalReference.new(NodeFactories::Schema)
          factory.call(context)
        end

        def examples_factory(context)
          factory = NodeFactory::OptionalReference.new(NodeFactories::Schema)
          NodeFactories::Map.new(context, value_factory: factory)
        end

        def content_factory(context)
          factory = NodeFactory::OptionalReference.new(
            NodeFactories::MediaType
          )
          NodeFactories::Map.new(context, value_factory: factory)
        end
      end
    end
  end
end
