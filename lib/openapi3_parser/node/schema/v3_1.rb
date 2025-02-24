# frozen_string_literal: true

require "openapi3_parser/node/schema"

module Openapi3Parser
  module Node
    class Schema < Node::Object
      # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#schemaObject
      #
      # With OpenAPI 3.1 Schemas are no longer defined as an OpenAPI object and
      # instead use the JSON Schema 2020-12 specification.
      #
      # The JSON Schema definition is rather complex with the ability to specify
      # different dialects and dynamic references, this doesn't attempt to model
      # these complexities and focuses on the core schema as defined in:
      # https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-01
      class V3_1 < Schema # rubocop:disable Naming/ClassAndModuleCamelCase
        # Whether this is a schema that is just a boolean value rather
        # than a schema object
        #
        # @return [Boolean]
        def boolean?
          !boolean.nil?
        end

        # Returns a boolean for a boolean schema [1] and nil for one based
        # on an object
        #
        # [1]: https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-00#section-4.3.2
        #
        # @return [Boolean, nil]
        def boolean
          self["boolean"]
        end

        # Returns true when this is a boolean schema that has a true value,
        # returns false for booleans schemas that have a false value or schemas
        # that are objects.
        #
        # @return [Boolean]
        def true?
          boolean == true
        end

        # Returns false when this is a boolean schema that has a false value,
        # returns false for booleans schemas that have a true value or schemas
        # that are objects.
        #
        # @return [Boolean]
        def false?
          boolean == false
        end

        # The schema dialect in usage, only https://spec.openapis.org/oas/3.1/dialect/base
        # is officially supported so others will receive a warning, but as
        # long they don't have different data types for keywords they'll be
        # mostly usable.
        #
        # @return [String]
        def json_schema_dialect
          self["$schema"] || node_context.document.json_schema_dialect
        end

        # @return [String, Node::Array<String>, nil]
        def type
          self["type"]
        end

        # @return [Any]
        def const
          self["const"]
        end

        # @return [Numeric]
        def exclusive_maximum
          self["exclusiveMaximum"]
        end

        # @return [Numeric]
        def exclusive_minimum
          self["exclusiveMinimum"]
        end

        # @return [Integer, nil]
        def max_contains
          self["maxContains"]
        end

        # @return [Integer]
        def min_contains
          self["minContains"]
        end

        # @return [Node::Array<Any>]
        def examples
          self["examples"]
        end

        # @return [Node::Map<String, Node::Array<String>>]
        def dependent_required
          self["dependentRequired"]
        end

        # @return [String, nil]
        def content_encoding
          self["contentEncoding"]
        end

        # @return [String, nil]
        def content_media_type
          self["contentMediaType"]
        end

        # @return [Schema, nil]
        def content_schema
          self["contentSchema"]
        end

        # @return [Schema, nil]
        def if
          self["if"]
        end

        # @return [Schema, nil]
        def then
          self["then"]
        end

        # @return [Schema, nil]
        def else
          self["else"]
        end

        # @return [Node::Map<String, Schema>]
        def dependent_schemas
          self["dependentSchemas"]
        end

        # @return [Node::Array<Schema>]
        def prefix_items
          self["prefixItems"]
        end

        # @return [Schema, nil]
        def contains
          self["contains"]
        end

        # @return [Node::Map<String, Schema>]
        def pattern_properties
          self["patternProperties"]
        end

        # @return [Schema, nil]
        def additional_properties
          self["additionalProperties"]
        end

        # @return [Boolean]
        def additional_properties?
          return false unless additional_properties

          !additional_properties.false?
        end

        # @return [Schema, nil]
        def unevaluated_items
          self["unevaluatedItems"]
        end

        # @return [Boolean]
        def unevaluated_items?
          return false unless unevaluated_items

          !unevaluated_items.false?
        end

        # @return [Schema, nil]
        def unevaluated_properties
          self["unevaluatedProperties"]
        end

        # @return [Boolean]
        def unevaluated_properties?
          return false unless unevaluated_properties

          !unevaluated_properties.false?
        end
      end
    end
  end
end
