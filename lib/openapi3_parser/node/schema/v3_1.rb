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
        # @return [String, Node::Array<String>, nil]
        def type
          self["type"]
        end

        # @return [Any]
        def const
          self["const"]
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

        # @return [Node::Array<Schema>]
        def prefix_items
          self["prefixItems"]
        end

        # @return [Schema, nil]
        def contains
          self["contains"]
        end
      end
    end
  end
end
