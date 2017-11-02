# frozen_string_literal: true

require "openapi_parser/node"
require "openapi_parser/fields/map"
require "openapi_parser/nodes/server_variable"

module OpenapiParser
  module Nodes
    class Server
      include Node

      allow_extensions

      field "url", input_type: String, required: true
      field "description", input_type: String
      field "variables", input_type: Hash, build: :build_server_variables_map

      # @TODO there's scope for an interpolated_url method which can use the
      # values from variables
      def url
        fields["url"]
      end

      def description
        fields["description"]
      end

      def variables
        fields["variables"]
      end

      private

      def build_server_variables_map(i, c)
        Fields::Map.call(i, c) do |input, context|
          ServerVariable.new(input, context)
        end
      end
    end
  end
end
