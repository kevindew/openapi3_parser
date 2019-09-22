# frozen_string_literal: true

require "openapi3_parser/node/object"

module Openapi3Parser
  module Node
    # @see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#licenseObject
    class License < Node::Object
      # @return [String]
      def name
        self["name"]
      end

      # @return [String, nil]
      def url
        self["url"]
      end
    end
  end
end
