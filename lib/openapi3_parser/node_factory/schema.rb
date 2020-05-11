# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    class Schema < NodeFactory::Object
      allow_extensions
      field "title", input_type: String
      field "multipleOf", input_type: Numeric
      field "maximum", input_type: Integer
      field "exclusiveMaximum", input_type: :boolean, default: false
      field "minimum", input_type: Integer
      field "exclusiveMinimum", input_type: :boolean, default: false
      field "maxLength", input_type: Integer
      field "minLength", input_type: Integer, default: 0
      field "pattern", input_type: String
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
            validate: :additional_properties_input_type,
            factory: :additional_properties_factory,
            default: false
      field "description", input_type: String
      field "format", input_type: String
      field "default"

      field "nullable", input_type: :boolean, default: false
      field "discriminator", factory: :discriminator_factory
      field "readOnly", input_type: :boolean, default: false
      field "writeOnly", input_type: :boolean, default: false
      field "xml", factory: :xml_factory
      field "externalDocs", factory: :external_docs_factory
      field "example"
      field "deprecated", input_type: :boolean, default: false

      validate :items_for_array, :read_only_or_write_only

      private

      def items_for_array(validatable)
        return unless validatable.input["type"] == "array"
        return unless validatable.factory.resolved_input["items"].nil?

        validatable.add_error("items must be defined for a type of array")
      end

      def read_only_or_write_only(validatable)
        input = validatable.input
        return if [input["readOnly"], input["writeOnly"]].uniq != [true]

        validatable.add_error("readOnly and writeOnly cannot both be true")
      end

      def build_object(data, context)
        Node::Schema.new(data, context)
      end

      def required_factory(context)
        NodeFactory::Array.new(
          context,
          default: nil,
          value_input_type: String
        )
      end

      def enum_factory(context)
        NodeFactory::Array.new(context, default: nil)
      end

      def discriminator_factory(context)
        NodeFactory::Discriminator.new(context)
      end

      def xml_factory(context)
        NodeFactory::Xml.new(context)
      end

      def external_docs_factory(context)
        NodeFactory::ExternalDocumentation.new(context)
      end

      def properties_factory(context)
        NodeFactory::Map.new(
          context,
          value_factory: NodeFactory::OptionalReference.new(self.class)
        )
      end

      def referenceable_schema(context)
        NodeFactory::OptionalReference.new(self.class).call(context)
      end

      def referenceable_schema_array(context)
        NodeFactory::Array.new(
          context,
          default: nil,
          value_factory: NodeFactory::OptionalReference.new(self.class)
        )
      end

      def additional_properties_input_type(validatable)
        input = validatable.input
        return if [true, false].include?(input) || input.is_a?(Hash)

        validatable.add_error("Expected a Boolean or an Object")
      end

      def additional_properties_factory(context)
        return context.input if [true, false].include?(context.input)

        referenceable_schema(context)
      end
    end
  end
end
