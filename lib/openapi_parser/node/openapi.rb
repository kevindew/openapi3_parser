# frozen_string_literal: true

module OpenapiParser
  class Node
    class Openapi < Node
      def openapi
        attributes["openapi"]
      end

      def info
        attributes["info"]
      end

      def servers
        attributes["servers"]
      end

      def paths
        attributes["paths"]
      end

      def components
        attributes["components"]
      end

      def security
        attributes["security"]
      end

      def tags
        attributes["tags"]
      end

      def external_docs
        attributes["externalDocs"]
      end

      private

      def build_info_node(input)
        return input unless input.respond_to?(:keys)
        Info.new(input, openapi_version)
      end
    end
  end
end
