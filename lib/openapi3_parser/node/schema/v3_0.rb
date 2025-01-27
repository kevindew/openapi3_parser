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
      end
    end
  end
end
