# frozen_string_literal: true

require "openapi3_parser/node_factory/object"
require "openapi3_parser/node_factory/referenceable"
require "openapi3_parser/validators/media_type"

module Openapi3Parser
  module NodeFactory
    module Schema
      class V3_1 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        using ArraySentence
        include Referenceable
        include Schema::Common
        JSON_SCHEMA_ALLOWED_TYPES = %w[null boolean object array number string integer].freeze

        # Allows any extension as per:
        # https://github.com/OAI/OpenAPI-Specification/blob/a1facce1b3621df3630cb692e9fbe18a7612ea6d/versions/3.1.0.md#fixed-fields-20
        allow_extensions(regex: /.*/)

        field "$ref", input_type: String, factory: :ref_factory
        field "type", factory: :type_factory, validate: :validate_type
        field "const"
        field "maxContains", input_type: Integer
        field "minContains", input_type: Integer, default: 1
        # dependentRequired - map with basic validation rules
        field "examples", factory: NodeFactory::Array
        field "contentEncoding", input_type: String
        field "contentMediaType",
              input_type: String,
              validate: Validation::InputValidator.new(Validators::MediaType)
        field "contentSchema", factory: :referenceable_schema
        field "if", factory: :referenceable_schema
        field "then", factory: :referenceable_schema
        field "else", factory: :referenceable_schema

        def build_node(data, node_context)
          Node::Schema::V3_1.new(data, node_context)
        end

        private

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
      end
    end
  end
end
