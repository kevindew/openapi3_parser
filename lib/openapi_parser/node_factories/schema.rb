# frozen_string_literal: true

require "openapi_parser/nodes/schema"
require "openapi_parser/node_factory/object"
require "openapi_parser/node_factories/map"

module OpenapiParser
  module NodeFactories
    class Schema
      include NodeFactory::Object

      allow_extensions
      field "title", input_type: String
      field "multipleOf", input_type: Numeric
      field "maximum", input_type: Integer
      field "exclusiveMaximum", input_type: :boolean, default: false
      field "minimum", input_type: Integer
      field "exclusiveMinimum", input_type: :boolean, default: false
      field "maxLength", input_type: Integer
      field "minLength", input_type: Integer, default: 0
      field :pattern, input_type: String
      field "maxItems", input_type: Integer
      field "minItems", input_type: Integer, default: 0
      field "uniqueItems", input_type: :boolean, default: false
      field "maxProperties", input_type: Integer
      field "minProperties", input_type: Integer, default: 0
      field "required", input_type: Array
      field "enum", input_type: Array

      field "type", input_type: String
      # field "allOf",
      #       input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
      #       build: :build_schema_array
      # field "oneOf",
      #       input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
      #       build: :build_schema_array
      # field "anyOf",
      #       input_type: HASH_ARRAY_WITH_ATLEAST_ONE_ELEMENT,
      #       build: :build_schema_array
      # field "not",
      #       input_type: Hash,
      #       build: :build_referenceable_schema
      # field "items",
      #       input_type: Hash,
      #       build: :build_referenceable_schema
      field "properties", factory: :properties_factory
      # field "additionalProperties",
      #       build: :build_additional_properties,
      #       input_type: ->(i) { [true, false].include?(i) || i.is_a?(Hash) }
      field "description", input_type: String
      field "format", input_type: String
      field "default"

      field "nullable", input_type: :boolean, default: false
      field "discriminator", factory: :disciminator_factory
      field "readOnly", input_type: :boolean, default: false
      field "writeOnly", input_type: :boolean, default: false
      field "xml", factory: :xml_factory
      field "externalDocs", factory: :external_docs_factory
      field "example"
      field "deprecated", input_type: :boolean, default: false

      private

      def build_object(data, context)
        Nodes::Schema.new(data, context)
      end

      def disciminator_factory(context)
        NodeFactories::Discriminator.new(context)
      end

      def xml_factory(context)
        NodeFactories::Xml.new(context)
      end

      def external_docs_factory(context)
        NodeFactories::ExternalDocumentation.new(context)
      end

      def properties_factory(context)
        NodeFactories::Map.new(
          context,
          value_factory: NodeFactories::Schema
        )
      end
    end
  end
end
