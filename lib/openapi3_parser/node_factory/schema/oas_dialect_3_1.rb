# frozen_string_literal: true

require "openapi3_parser/node_factory/object"

module Openapi3Parser
  module NodeFactory
    module Schema
      class OasDialect3_1 < NodeFactory::Object # rubocop:disable Naming/ClassAndModuleCamelCase
        # Allows any extension as per:
        # https://github.com/OAI/OpenAPI-Specification/blob/a1facce1b3621df3630cb692e9fbe18a7612ea6d/versions/3.1.0.md#fixed-fields-20
        allow_extensions(regex: /.*/)
      end
    end
  end
end
