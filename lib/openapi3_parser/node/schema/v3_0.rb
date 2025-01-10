# frozen_string_literal: true

require "openapi3_parser/node/schema"

module Openapi3Parser
  module Node
    class Schema < Node::Object
      # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject
      class V3_0 < Schema # rubocop:disable Naming/ClassAndModuleCamelCase
      end
    end
  end
end
