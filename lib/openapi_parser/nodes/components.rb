# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/schema"
require "openapi_parser/nodes/response"
require "openapi_parser/nodes/parameter"

module OpenapiParser
  module Nodes
    class Components
      include Node

      allow_extensions

      field "schemas",
            input_type: Hash,
            build: :build_schemas_map

      field "responses",
            input_type: Hash,
            build: :build_responses_map

      field "parameters",
            input_type: Hash,
            build: :build_parameters_map

      def schemas
        fields["schemas"]
      end

      def responses
        fields["responses"]
      end

      def parameters
        fields["parameters"]
      end

      private

      def build_schemas_map(i, c)
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          Schema.new(resolved_input, resolved_context)
        end
      end

      def build_responses_map(i, c)
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          Response.new(resolved_input, resolved_context)
        end
      end

      def build_parameters_map(i, c)
        Fields::Map.reference_input(i, c) do |resolved_input, resolved_context|
          Parameter.new(resolved_input, resolved_context)
        end
      end
    end
  end
end
