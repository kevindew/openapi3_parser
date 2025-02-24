# frozen_string_literal: true

require "openapi3_parser/node/schema"

module Openapi3Parser
  module Node
    class Schema < Node::Object
      # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject
      class V3_0 < Schema # rubocop:disable Naming/ClassAndModuleCamelCase
        # @return [String, nil]
        def type
          self["type"]
        end

        # @return [Boolean]
        def exclusive_maximum?
          self["exclusiveMaximum"]
        end

        # @return [Boolean]
        def exclusive_minimum?
          self["exclusiveMinimum"]
        end

        # @return [Boolean]
        def additional_properties?
          self["additionalProperties"] != false
        end

        # @return [Schema, nil]
        def additional_properties_schema
          properties = self["additionalProperties"]
          return if [true, false].include?(properties)

          properties
        end
      end
    end
  end
end
