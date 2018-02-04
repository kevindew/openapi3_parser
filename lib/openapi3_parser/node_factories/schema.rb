# frozen_string_literal: true

require "openapi3_parser/node/schema"
require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/optional_reference"
require "openapi3_parser/node_factories/map"
require "openapi3_parser/node_factories/array"
require "openapi3_parser/node_factories/external_documentation"
require "openapi3_parser/node_factories/discriminator"
require "openapi3_parser/node_factories/xml"

module Openapi3Parser
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
      field "required", factory: :required_factory
      field "enum", factory: :enum_factory

      field "type", input_type: String
      field "allOf", factory: :referenceable_schema_array
      field "oneOf", factory: :referenceable_schema_array
      field "anyOf", factory: :referenceable_schema_array
      field "not", factory: :referenceable_schema
      field "items", factory: :referenceable_schema
      field "properties", factory: :properties_factory
      field "additionalProperties",
            input_type: :additional_properties_input_type,
            factory: :additional_properties_factory,
            default: false
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
        Node::Schema.new(data, context)
      end

      def required_factory(context)
        NodeFactories::Array.new(
          context,
          default: nil,
          value_input_type: String
        )
      end

      def enum_factory(context)
        NodeFactories::Array.new(context, default: nil)
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

      def referenceable_schema(context)
        NodeFactory::OptionalReference.new(self.class).call(context)
      end

      def referenceable_schema_array(context)
        NodeFactories::Array.new(
          context,
          default: nil,
          value_factory: NodeFactory::OptionalReference.new(self.class)
        )
      end

      def additional_properties_input_type(input)
        return if [true, false].include?(input) || input.is_a?(Hash)
        "Expected a boolean or an object"
      end

      def additional_properties_factory(context)
        return context.input if [true, false].include?(context.input)
        referenceable_schema(context)
      end
    end
  end
end
