# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/referenceable"
require "openapi3_parser/node_factory/schema/common"
require "openapi3_parser/validators/media_type"

module Openapi3Parser
  module NodeFactory
    module Schema
      # rubocop:disable Metrics/ClassLength
      class V3_1 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        using ArraySentence
        include Referenceable
        include Schema::Common
        JSON_SCHEMA_ALLOWED_TYPES = %w[null boolean object array number string integer].freeze
        OAS_DIALECT = "https://spec.openapis.org/oas/3.1/dialect/base"

        # Allows any extension as per:
        # https://github.com/OAI/OpenAPI-Specification/blob/a1facce1b3621df3630cb692e9fbe18a7612ea6d/versions/3.1.0.md#fixed-fields-20
        allow_extensions(regex: /.*/)

        field "$ref", input_type: String, factory: :ref_factory
        field "$schema",
              input_type: String,
              validate: Validation::InputValidator.new(Validators::Uri)
        field "type", factory: :type_factory, validate: :validate_type
        field "const"
        field "exclusiveMaximum", input_type: Numeric
        field "exclusiveMinimum", input_type: Numeric
        field "maxContains", input_type: Integer
        field "minContains", input_type: Integer, default: 1
        field "examples", factory: NodeFactory::Array
        field "dependentRequired", factory: :dependent_required_factory
        field "contentEncoding", input_type: String
        field "contentMediaType",
              input_type: String,
              validate: Validation::InputValidator.new(Validators::MediaType)
        field "contentSchema", factory: :referenceable_schema
        field "if", factory: :referenceable_schema
        field "then", factory: :referenceable_schema
        field "else", factory: :referenceable_schema
        field "dependentSchemas", factory: :schema_map_factory
        field "prefixItems", factory: :prefix_items_factory
        field "contains", factory: :referenceable_schema
        field "patternProperties", factory: :schema_map_factory
        field "additionalProperties", factory: :referenceable_schema
        field "unevaluatedItems", factory: :referenceable_schema
        field "unevaluatedProperties", factory: :referenceable_schema

        validate do |validatable|
          # if we do more with supporting $schema we probably want it to be
          # a value in the context object so it can cascade appropariately
          document = validatable.context.source_location.document
          dialect = validatable.input["$schema"] || document.resolved_input_at("#/jsonSchemaDialect")

          next if dialect.nil? || dialect == OAS_DIALECT

          document.unsupported_schema_dialect(dialect.to_s)
        end

        def boolean_input?
          [true, false].include?(resolved_input)
        end

        def errors
          # It's a bit janky that we do this method overloading here to handle
          # the dual types of a 3.1 Schema. However this is the only node we
          # have this dual type behaviour. We should do something more clever
          # in the factories if there is further precedent.
          @errors ||= if boolean_input?
                        Validation::ErrorCollection.new
                      elsif raw_input && !raw_input.is_a?(::Hash)
                        error = Validation::Error.new(
                          "Invalid type. Expected Object or Boolean",
                          context,
                          self.class
                        )
                        Validation::ErrorCollection.new([error])
                      else
                        super
                      end
        end

        def node(node_context)
          # as per #errors above, this is a bit of a nasty hack to handle
          # dual type handling and should be refactored should there be
          # other nodes with the same needs
          if boolean_input?
            Node::Schema::V3_1.new({ "boolean" => resolved_input }, node_context)
          elsif raw_input && !raw_input.is_a?(::Hash)
            raise Error::InvalidType,
                  "Invalid type for #{context.location_summary}: " \
                  "Expected Object or Boolean"
          else
            super
          end
        end

        def build_node(data, node_context)
          Node::Schema::V3_1.new(data, node_context)
        end

        private

        def build_data(raw_input)
          return raw_input if [true, false].include?(raw_input)

          super
        end

        def ref_factory(context)
          NodeFactory::Fields::Reference.new(context, self.class)
        end

        def type_factory(context)
          # Short circuit that we don't actually want to create a factory if we
          # have string or nil input, and instead just want the data
          return context.input if context.input.is_a?(String) || context.input.nil?

          NodeFactory::Array.new(context,
                                 default: nil,
                                 value_input_type: String)
        end

        def validate_type(validatable)
          return unless validatable.input

          input = validatable.input
          allowed_types = JSON_SCHEMA_ALLOWED_TYPES

          case input
          when String
            unless allowed_types.include?(input)
              validatable.add_error("type (#{input}) must be one of #{allowed_types.sentence_join}")
            end
          when ::Array
            validatable.add_error("Duplicate entries in type array") if input.uniq.count != input.count

            if (difference = input.difference(allowed_types)).any?
              validatable.add_error(
                "type contains unexpected items (#{difference.sentence_join}) " \
                "outside of #{allowed_types.sentence_join}"
              )
            end
          else
            validatable.add_error("type must be a string or an array")
          end
        end

        def dependent_required_factory(context)
          value_factory = lambda do |value_context|
            NodeFactory::Array.new(value_context, value_input_type: String)
          end

          NodeFactory::Map.new(
            context,
            value_factory:
          )
        end

        def prefix_items_factory(context)
          NodeFactory::Array.new(
            context,
            value_factory: NodeFactory::Schema.factory(context)
          )
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
