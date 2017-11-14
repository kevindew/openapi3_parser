# frozen_string_literal: true

require "openapi_parser/node"

module OpenapiParser
  module Nodes
    class License

      attr_reader :data, :context

      def initialize(data, context)
        @data = data
        @context = context
      end

      def name
        data["name"]
      end

      def url
        data["url"]
      end
    end
  end
end
