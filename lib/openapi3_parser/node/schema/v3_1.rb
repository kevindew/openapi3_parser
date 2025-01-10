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
      end
    end
  end
end
