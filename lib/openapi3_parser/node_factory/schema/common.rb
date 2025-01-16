# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    module Schema
      # This module contains methods and configuration that are consistent
      # across all schema node factories and mixed into them.
      module Common
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def self.included(base)
          base.field "title", input_type: String

          base.field "multipleOf", input_type: Numeric
          base.field "maximum", input_type: Integer
          base.field "exclusiveMaximum", input_type: :boolean, default: false
          base.field "minimum", input_type: Integer
          base.field "exclusiveMinimum", input_type: :boolean, default: false
          base.field "maxLength", input_type: Integer
          base.field "minLength", input_type: Integer, default: 0
          base.field "pattern", input_type: String
          base.field "maxItems", input_type: Integer
          base.field "minItems", input_type: Integer, default: 0
          base.field "uniqueItems", input_type: :boolean, default: false
          base.field "maxProperties", input_type: Integer
          base.field "minProperties", input_type: Integer, default: 0
          base.field "required", factory: :required_factory
          base.field "enum", factory: :enum_factory

          base.field "allOf", factory: :referenceable_schema_array
          base.field "oneOf", factory: :referenceable_schema_array
          base.field "anyOf", factory: :referenceable_schema_array
          base.field "not", factory: :referenceable_schema
          base.field "items", factory: :referenceable_schema
          base.field "properties", factory: :properties_factory
          base.field "additionalProperties",
                     validate: :additional_properties_input_type,
                     factory: :additional_properties_factory,
                     default: false
          base.field "description", input_type: String
          base.field "format", input_type: String
          base.field "default"

          base.field "nullable", input_type: :boolean, default: false
          base.field "discriminator", factory: :discriminator_factory
          base.field "readOnly", input_type: :boolean, default: false
          base.field "writeOnly", input_type: :boolean, default: false
          base.field "xml", factory: :xml_factory
          base.field "externalDocs", factory: :external_docs_factory
          base.field "example"
          base.field "deprecated", input_type: :boolean, default: false

          base.validate :read_only_or_write_only
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        private

        def read_only_or_write_only(validatable)
          input = validatable.input
          return if [input["readOnly"], input["writeOnly"]].uniq != [true]

          validatable.add_error("readOnly and writeOnly cannot both be true")
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
            value_factory: NodeFactory::Schema.factory(context)
          )
        end

        def referenceable_schema(context)
          NodeFactory::Schema.build_factory(context)
        end

        def referenceable_schema_array(context)
          NodeFactory::Array.new(
            context,
            default: nil,
            value_factory: NodeFactory::Schema.factory(context)
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
end
